
import SwiftUI
import UIKit
import Compression
import CoreData

struct ManageRunPlansView: View {
    @FetchRequest(
        entity: RunPlan.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \RunPlan.name, ascending: true)]
    ) private var runPlans: FetchedResults<RunPlan>
    @State private var showAddPlanSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(runPlans, id: \.objectID) { runPlan in
                        NavigationLink(destination: EditRunPlanView(runPlan: runPlan)) {
                            Text(runPlan.name ?? NSLocalizedString("unknown_plan", comment: "Unknown Plan"))
                        }
                    }
                    .onDelete(perform: deleteRunPlan)
                }
                .navigationTitle(NSLocalizedString("manage_run_plans", comment: "Manage Run Plans"))
                .navigationBarItems(trailing: Button(action: {
                    showAddPlanSheet.toggle()
                }) {
                    Image(systemName: "plus")
                })
                .sheet(isPresented: $showAddPlanSheet) {
                    AddRunPlanView()
                }
            }
        }
    }
    
    private func deleteRunPlan(at offsets: IndexSet) {
        for index in offsets {
            let plan = runPlans[index]
            CoreDataManager.shared.context.delete(plan)
        }
        CoreDataManager.shared.saveContext()
    }
}

struct EditRunPlanView: View {
    @ObservedObject var runPlan: RunPlan
    @State private var showAddStageSheet = false
    @State private var showingCopiedAlert = false
    @State private var isDuplicateName = false
    
    var body: some View {
        VStack {
            TextField(NSLocalizedString("plan_name", comment: "Plan Name"), text: Binding(get: { runPlan.name ?? "" }, set: { newValue in
                runPlan.name = newValue
                CoreDataManager.shared.saveContext()
            }))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .onChange(of: runPlan.name) { newName in
                if let newName = newName {
                    isDuplicateName = CoreDataManager.shared.fetchAllRunPlans().contains { $0.name == newName && $0 != runPlan }
                }
            }
            .alert(isPresented: $isDuplicateName) {
                Alert(title: Text(NSLocalizedString("duplicate_plan_name", comment: "Plan name already exists, please change it.")), dismissButton: .default(Text(NSLocalizedString("ok", comment: "OK"))))
            }
            .foregroundColor(isDuplicateName ? .red : .primary)
            
            List {
                ForEach(runPlan.stagesArray, id: \.objectID) { stage in
                    HStack {
                        TextField(NSLocalizedString("stage_name", comment: "Stage Name"), text: Binding(
                            get: { stage.name ?? "" },
                            set: { newValue in
                                stage.name = newValue
                                CoreDataManager.shared.saveContext()
                            }
                        ))
                        TextField(NSLocalizedString("distance", comment: "Distance"), value: Binding(
                            get: { stage.distance },
                            set: { newValue in
                                stage.distance = newValue
                                CoreDataManager.shared.saveContext()
                            }
                        ), formatter: NumberFormatter())
                    }
                }
                .onDelete(perform: deleteStage)
            }
            
            Button(NSLocalizedString("add_new_stage", comment: "Add New Stage")) {
                showAddStageSheet.toggle()
            }
            .sheet(isPresented: $showAddStageSheet) {
                AddRunStageView(onAdd: { newStage in
                    let nextIndex = runPlan.stagesArray.count
                    let indexedStage = RunStage(context: CoreDataManager.shared.context)
                    indexedStage.id = UUID()
                    indexedStage.name = newStage.name
                    indexedStage.distance = newStage.distance
                    indexedStage.index = Int64(nextIndex)
                    indexedStage.plan = runPlan
                    
                    runPlan.mutableSetValue(forKey: "stages").add(indexedStage)
                    
                    do {
                        try CoreDataManager.shared.context.save()
                    } catch {
                        print("Failed to save new stage: \(error)")
                    }
                }, nextIndex: runPlan.stagesArray.count)
            }
            
            Button(action: shareRunPlan) {
                Image(systemName: "square.and.arrow.up")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding()
            }
            .alert(isPresented: $showingCopiedAlert) {
                Alert(title: Text(NSLocalizedString("copied_to_clipboard", comment: "Copied to Clipboard")), message: nil, dismissButton: .default(Text(NSLocalizedString("ok", comment: "OK"))))
            }
        }
        .navigationTitle(NSLocalizedString("edit_run_plan", comment: "Edit Run Plan"))
    }
    
    private func deleteStage(at offsets: IndexSet) {
        for index in offsets {
            let stage = runPlan.stagesArray[index]
            CoreDataManager.shared.context.delete(stage)
        }
        CoreDataManager.shared.saveContext()
    }
    
    private func shareRunPlan() {
        let sharedPlan = SharedRunPlan(
            name: runPlan.name ?? "",
            stages: runPlan.stagesArray.map { SharedRunStage(index: Int($0.index), name: $0.name ?? "", distance: $0.distance) }
        )
        
        guard let jsonData = try? JSONEncoder().encode(sharedPlan),
              let compressedData = compress(data: jsonData) else {
            print(NSLocalizedString("share_failed", comment: "Share Failed"))
            return
        }
        let base64String = compressedData.base64EncodedString()
        UIPasteboard.general.string = base64String
        showingCopiedAlert = true
    }
    
    private func compress(data: Data) -> Data? {
        var compressedData = Data()
        data.withUnsafeBytes { (srcPointer: UnsafeRawBufferPointer) in
            let srcBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
            srcBuffer.assign(from: srcPointer.bindMemory(to: UInt8.self).baseAddress!, count: data.count)
            
            let dstBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
            let compressedSize = compression_encode_buffer(dstBuffer, data.count * 4, srcBuffer, data.count, nil, COMPRESSION_ZLIB)
            if compressedSize > 0 {
                compressedData.append(dstBuffer, count: compressedSize)
            }
            srcBuffer.deallocate()
            dstBuffer.deallocate()
        }
        return compressedData
    }
}

struct AddRunPlanView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    @State private var planName: String = ""
    @State private var stages: [RunStage] = []
    @State private var pastedText: String = ""
    @State private var isDuplicateName = false
    @State private var showingParseErrorAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(NSLocalizedString("plan_name", comment: "Plan Name"))) {
                    TextField(NSLocalizedString("plan_name", comment: "Name"), text: $planName)
                        .onChange(of: planName) { newName in
                            isDuplicateName = CoreDataManager.shared.fetchAllRunPlans().contains { $0.name == newName }
                        }
                    if isDuplicateName {
                        Text(NSLocalizedString("duplicate_plan_name", comment: "Plan name already exists, please change it."))
                            .foregroundColor(.red)
                    }
                }
                
                Section(header: Text(NSLocalizedString("paste_and_identify", comment: "Paste and Identify"))) {
                    TextEditor(text: $pastedText)
                        .frame(minHeight: 100)
                    
                    Button(NSLocalizedString("paste_and_identify", comment: "Paste and Identify")) {
                        if let clipboardText = UIPasteboard.general.string {
                            pastedText = clipboardText
                            if pastedText.isEmpty || !isValidPlan(pastedText) {
                                showingParseErrorAlert = true
                            } else {
                                addRunPlan(from: pastedText)
                            }
                        }
                    }
                    .alert(isPresented: $showingParseErrorAlert) {
                        Alert(title: Text(NSLocalizedString("parse_failed", comment: "Parse Failed")), message: Text(NSLocalizedString("cannot_parse_text", comment: "Cannot parse pasted text, please check the input.")), dismissButton: .default(Text(NSLocalizedString("ok", comment: "OK"))))
                    }
                }
                
                Section(header: Text(NSLocalizedString("stage_name", comment: "Stages"))) {
                    List {
                        ForEach(stages, id: \.self) { stage in
                            HStack {
                                TextField(NSLocalizedString("stage_name", comment: "Stage Name"), text: Binding(
                                    get: { stage.name ?? "" },
                                    set: { stage.name = $0 }
                                ))
                                TextField(NSLocalizedString("distance", comment: "Distance"), value: Binding(
                                    get: { stage.distance },
                                    set: { stage.distance = $0 }
                                ), formatter: NumberFormatter())
                            }
                        }
                        .onDelete(perform: deleteStage)
                    }
                    Button(NSLocalizedString("add_stage", comment: "Add Stage")) {
                        let newStage = RunStage(context: CoreDataManager.shared.context)
                        newStage.id = UUID()
                        newStage.name = NSLocalizedString("add_new_stage", comment: "New Stage")
                        newStage.distance = 0
                        stages.append(newStage)
                    }
                }
            }
            .navigationTitle(NSLocalizedString("add_run_plan", comment: "Add Run Plan"))
            .navigationBarItems(leading: Button(NSLocalizedString("cancel", comment: "Cancel")) {
                dismiss()
            }, trailing: Button(NSLocalizedString("add", comment: "Add")) {
                if !isDuplicateName {
                    let newPlan = RunPlan(context: context)
                    newPlan.id = UUID()
                    newPlan.name = planName
                    for stageData in stages {
                        let newStage = RunStage(context: context)
                        newStage.id = UUID()
                        newStage.name = stageData.name
                        newStage.distance = stageData.distance
                        newStage.index = Int64(stages.firstIndex(of: stageData) ?? 0)
                        newStage.plan = newPlan
                    }
                    CoreDataManager.shared.saveContext()
                    dismiss()
                }
            })
        }
    }
    
    private func addRunPlan(from pastedText: String) {
        guard !pastedText.isEmpty else { return }
        guard let decodedData = Data(base64Encoded: pastedText),
              let decompressedData = decompress(data: decodedData),
              let sharedPlan = try? JSONDecoder().decode(SharedRunPlan.self, from: decompressedData) else {
            print(NSLocalizedString("parse_failed", comment: "Parse Failed"))
            showingParseErrorAlert = true
            return
        }
        planName = sharedPlan.name
        stages = sharedPlan.stages.map { sharedStage in
            let stage = RunStage(context: CoreDataManager.shared.context)
            stage.id = UUID()
            stage.name = sharedStage.name
            stage.distance = sharedStage.distance
            stage.index = Int64(sharedStage.index)
            return stage
        }
    }
    
    private func isValidPlan(_ text: String) -> Bool {
        guard let decodedData = Data(base64Encoded: text),
              let _ = decompress(data: decodedData) else {
            return false
        }
        return true
    }
    
    func decompress(data: Data) -> Data? {
        var decompressedData = Data()
        data.withUnsafeBytes { (srcPointer: UnsafeRawBufferPointer) in
            let srcBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
            srcBuffer.assign(from: srcPointer.bindMemory(to: UInt8.self).baseAddress!, count: data.count)
            
            let dstBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count * 4)
            let decompressedSize = compression_decode_buffer(dstBuffer, data.count * 4, srcBuffer, data.count, nil, COMPRESSION_ZLIB)
            if decompressedSize > 0 {
                decompressedData.append(dstBuffer, count: decompressedSize)
            }
            srcBuffer.deallocate()
            dstBuffer.deallocate()
        }
        return decompressedData
    }
    
    private func deleteStage(at offsets: IndexSet) {
        stages.remove(atOffsets: offsets)
    }
}

struct AddRunStageView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var stageName: String = ""
    @State private var stageDistance: Double = 0.0
    var onAdd: (RunStage) -> Void
    var nextIndex: Int
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(NSLocalizedString("stage_name", comment: "Stage Name"))) {
                    TextField(NSLocalizedString("plan_name", comment: "Name"), text: $stageName)
                }
                
                Section(header: Text(NSLocalizedString("stage_distance", comment: "Stage Distance (meters)"))) {
                    TextField(NSLocalizedString("distance", comment: "Distance"), value: $stageDistance, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle(NSLocalizedString("add_new_stage", comment: "Add New Stage"))
            .navigationBarItems(leading: Button(NSLocalizedString("cancel", comment: "Cancel")) {
                dismiss()
            }, trailing: Button(NSLocalizedString("add", comment: "Add")) {
                let newStage = RunStage(context: CoreDataManager.shared.context)
                newStage.id = UUID()
                newStage.name = stageName
                newStage.distance = stageDistance
                newStage.index = Int64(nextIndex)
                onAdd(newStage)
                dismiss()
                })
        }
    }
}

//
//	TaskInfo.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation
import KakaJSON

class TaskInfo : Convertible {

	let createdAt : Int64?
	let task : TaskBrief?
	let taskId : Int64?
    
	enum CodingKeys: String, CodingKey {
		case createdAt = "createdAt"
		case task = "task"
		case taskId = "taskId"
	}
    
    required init() {
        createdAt = nil
        task = nil
        taskId = nil
    }


}

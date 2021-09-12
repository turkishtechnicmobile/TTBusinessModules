//
//  BaseApiGatewayServices.swift
//  NMBusinessModules
//
//  Created by Nazif MASMANACI on 6.05.2021.
//  Copyright © 2021 Turkish Technic. All rights reserved.
//

import Foundation
import TTBaseApp
import TTBaseModel
import TTBaseService

open class BaseApiGatewayServices {
    typealias QueryParameters = [String: String]
    public static let shared = BaseApiGatewayServices()
    
    @Inject public var persistent: Persistent
    @Inject public var dateFormat: DateFormat
    @Inject public var service: ServiceProtocol
    
    private var noBody: BaseModel?
    private let status = "ACTIVE"
    
    var headers: [String: String] {
        var headers = [
            "Content-Type": "application/json",
            "lang": "tr-TR"
        ]
        
        if let accessToken = persistent.accessToken {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        return headers
    }
    
    var coreHeaders: [String: String] {
        var headers = [
            "Content-Type": "application/json",
            "lang": "tr-TR"
        ]
        
        if let token = persistent.token {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }
    
    /*
    var baseUrl: URL {
        #if DEVELOPMENT
        let testProd = "test"
        #else
        let testProd = "prod"
        #endif
        
        let baseUrlString = "https://mobileupdate.thyteknik.com.tr/\(testProd)/api"
        return URL(string: baseUrlString)!
    }
    
    var baseCoreUrl: URL {
        #if DEVELOPMENT
        let testProd = "test"
        #else
        let testProd = ""
        #endif
        
        let baseUrlString = "https://mobileupdate.thyteknik.com.tr/coreassistant\(testProd)"
        return URL(string: baseUrlString)!
    }
    */
    
    private func execute<T, R>(path: ServicePath, with method: HttpMethod = .post, body: T?, parameters: QueryParameters?, completion: @escaping (Result<BaseResponse<R>, BaseError>) -> Void) -> Cancelable where T: Model, R: Model {
        
        guard let urlRequest = createRequest(path: path, with: method, body: body, parameters: parameters) else {
            completion(.failure(.invalidRequest))
            return Disposables.create()
        }
        // MNM print işlemleri service.execute(with: urlRequest, options:[.debugPrint], completion: completion)
        return service.execute(with: urlRequest, completion: completion)
    }
    
    private func createRequest<T>(path: ServicePath, with method: HttpMethod, body: T?, parameters: QueryParameters?) -> URLRequest? where T: Model {
        
        
      //  let pathResource = path.rawValue
      //  let serviceUrl = (path.isCore ? baseCoreUrl: baseUrl).appendingPathComponent(pathResource)
        guard var urlComponents = URLComponents(string: path.description) else { return nil }
        urlComponents.queryItems = parameters?.compactMap { URLQueryItem(name: $0, value: $1) }
        
        guard let url = urlComponents.url else { return nil }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = path.isCore ? coreHeaders: headers
        
        if let body = body {
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .formatted(dateFormat.apiDateFormatter)
                urlRequest.httpBody = try encoder.encode(body)
            } catch let encodeError {
                debugPrint("Error: when encoding \(#function): \(encodeError)")
                return nil
            }
        }
        
        return urlRequest
    }
    
}

// MARK: - Implementation
extension BaseApiGatewayServices: APIGatewayService {
    
    public func getFleets(completion: @escaping (Result<BaseResponse<FleetResponse>, BaseError>) -> Void) -> Cancelable {
        let path = ServicePath.getFleet
        return execute(path: path, with: .get, body: noBody, parameters: nil, completion: completion)
    }
    
    public func getAirCrafts(completion: @escaping (Result<BaseResponse<AcMasterResponse>, BaseError>) -> Void) -> Cancelable {
        let path = ServicePath.getAllFlightList
        let parameters: QueryParameters = ["Status": status]
        return execute(path: path, with: .get, body: noBody, parameters: parameters, completion: completion)
    }
    
    public func getLocations(completion: @escaping (Result<BaseResponse<LocationResponseRem>, BaseError>) -> Void) -> Cancelable {
        let path = ServicePath.getLocationList
        return execute(path: path, with: .get, body: noBody, parameters: nil, completion: completion)
    }
    
    public func getChapters(completion: @escaping (Result<BaseResponse<ChapterResponse>, BaseError>) -> Void) -> Cancelable {
        let path = ServicePath.getChapter
        return execute(path: path, with: .get, body: noBody, parameters: nil, completion: completion)
    }
    
    public func getSections(of chapter: Int, completion: @escaping (Result<BaseResponse<SectionResponse>, BaseError>) -> Void) -> Cancelable {
        let path = ServicePath.getSection
        let parameters: QueryParameters = ["Chapter": String(chapter)]
        return execute(path: path, with: .get, body: noBody, parameters: parameters, completion: completion)
    }
    
    public func getTranCodes(with type: TranCodeType, completion: @escaping (Result<BaseResponse<TranCodeResponse>, BaseError>) -> Void) -> Cancelable {
        let path = ServicePath.tranCode
        let parameters: QueryParameters = ["Status": status, "TranCode": type.rawValue]
        return execute(path: path, with: .get, body: noBody, parameters: parameters, completion: completion)
    }
    
    public func getEmployee(by employeeID: String, completion: @escaping (Result<BaseResponse<EmployeeResponse>, BaseError>) -> Void) -> Cancelable {
        let path = ServicePath.checkEmployee
        let parameters: QueryParameters = ["Status": status, "RelationCode": employeeID]
        return execute(path: path, with: .get, body: noBody, parameters: parameters, completion: completion)
    }
    
    public func getAcUnitsBy(ac: String, completion: @escaping (Result<BaseResponse<AcMasterResponse>, BaseError>) -> Void) -> Cancelable {
        let path = ServicePath.getAllFlightList
        let parameters: QueryParameters = ["Status": status, "Ac": ac]
        return execute(path: path, with: .get, body: noBody, parameters: parameters, completion: completion)
    }
    
    public func getSkills(completion: @escaping (Result<BaseResponse<SkillResponse>, BaseError>) -> Void) -> Cancelable {
        let path = ServicePath.getSkill
        let parameters: QueryParameters = ["Status": status]
        return execute(path: path, with: .get, body: noBody, parameters: parameters, completion: completion)
    }
    
    public func getCdrmLocations(fleet: String, completion: @escaping (Result<BaseResponse<CdrmLocationResponse>, BaseError>) -> Void) -> Cancelable {
        let path = ServicePath.getCdrmLocation
        let parameters: QueryParameters = ["fleet": fleet]
        return execute(path: path, with: .get, body: noBody, parameters: parameters, completion: completion)
    }
    
    public func getCdrmParts(fleet: String, mainWhere: String, completion: @escaping (Result<BaseResponse<CdrmPartResponse>, BaseError>) -> Void) -> Cancelable {
        let path = ServicePath.getCdrmPart
        let parameters: QueryParameters = ["fleet": fleet, "main_where": mainWhere]
        return execute(path: path, with: .get, body: noBody, parameters: parameters, completion: completion)
    }
    
    public func getCdrmDescriptions(fleet: String, mainWhere: String, what: String, completion: @escaping (Result<BaseResponse<CdrmDecriptionResponse>, BaseError>) -> Void) -> Cancelable {
        let path = ServicePath.getCdrmPartDesc
        let parameters: QueryParameters = ["fleet": fleet, "main_where": mainWhere, "what": what]
        return execute(path: path, with: .get, body: noBody, parameters: parameters, completion: completion)
    }
    
    public func getDefectReportsByAc(with body: Defect, completion: @escaping (Result<BaseResponse<DefectReportListResponse>, BaseError>) -> Void) -> Cancelable {
        let path = ServicePath.getDefectReportsByAc
        return execute(path: path, with: .post, body: body, parameters: nil, completion: completion)
    }
    
    // MARK: - Detail
    public func defectReport(method: HttpMethod, with body: Defect, completion: @escaping (Result<BaseResponse<DefectReportResponse>, BaseError>) -> Void) -> Cancelable {
        var path: ServicePath
        
        switch method {
        case .get:
            path = .getDefectReport
        case .post, .put:
            path = .setDefect
        case .remove:
            path = .closeDefect
        }
        
        return execute(path: path, with: .post, body: body, parameters: nil, completion: completion)
    }
    
    // MARK: - Defer
    public func defectReportDefer(with body: Defect, completion: @escaping (Result<BaseResponse<DefectReportDeferResponse>, BaseError>) -> Void) -> Cancelable {
        let path = ServicePath.deferDefect
        return execute(path: path, with: .post, body: body, parameters: nil, completion: completion)
    }
    
    // MARK: - Pn
    public func defectReportPn<T: DefectReportPn>(method: HttpMethod, with body: T, completion: @escaping (Result<BaseResponse<DefectReportPnResponse>, BaseError>) -> Void) -> Cancelable {
        
        var path: ServicePath
        switch method {
        case .get:
            path = .getDefectReportPn
        case .post, .put:
            path = .addOrUpdateDefectPnRequirement
        case .remove:
            path = .removeDefectreportPn
        }
        
        return execute(path: path, with: .post, body: body, parameters: nil, completion: completion)
    }
    
    // MARK: - Trouble Shooting
    public func defectReportTroubleShooting(method: HttpMethod, with body: DefectReportTroubleShooting, completion: @escaping (Result<BaseResponse<DefectReportTroubleShootingResponse>, BaseError>) -> Void) -> Cancelable {
        var path: ServicePath
        switch method {
        case .get:
            path = .getDefectReportTroubleShooting
        case .post, .put:
            path = .addOrUpdateDefectTroubleShooting
        case .remove:
            path = .removeDefectreportTroubleShooting
        }
        
        return execute(path: path, with: .post, body: body, parameters: nil, completion: completion)
    }
    
    // MARK: - Resolution
    public func defectReportResolution(with body: Defect, completion: @escaping (Result<BaseResponse<DefectReportResponse>, BaseError>) -> Void) -> Cancelable {
        return defectReport(method: .remove, with: body, completion: completion)
    }
    
    public func getDefectMels(with body: DefectMel, completion: @escaping (Result<BaseResponse<DefectMelResponse>, BaseError>) -> Void) -> Cancelable {
        let path = ServicePath.getDefectMels
        return execute(path: path, with: .post, body: body, parameters: nil, completion: completion)
    }
    
    public func getDefectCategoryCdrmConfigurations(completion: @escaping (Result<BaseResponse<DefectCategoryCdrmConfigResponse>, BaseError>) -> Void) -> Cancelable {
        let path = ServicePath.getCabinDefectCategoryConfig
        return execute(path: path, with: .get, body: noBody, parameters: nil, completion: completion)
    }
    
    // MARK: - Work Orders
    public func getWorkOrders(with body: WorkOrder, completion: @escaping (Result<BaseResponse<WorkOrderResponse>, BaseError>) -> Void) -> Cancelable {
        let path = ServicePath.getWorkOrders
        return execute(path: path, with: .post, body: body, parameters: nil, completion: completion)
    }
    
    // MARK: - Archive
    public func getDefectReportsArchive(with body: Defect, completion: @escaping (Result<BaseResponse<DefectReportListResponse>, BaseError>) -> Void) -> Cancelable {
        let path = ServicePath.getDefectReportsArchive
        return execute(path: path, with: .post, body: body, parameters: nil, completion: completion)
    }
    
    public func registerDeviceToken(with body: DeviceToken, completion: @escaping (Result<BaseResponse<BaseModel>, BaseError>) -> Void) -> Cancelable {
        let path = ServicePath.addOrUpdateDeviceToken
        return execute(path: path, with: .post, body: body, parameters: nil, completion: completion)
    }
    
    // MARK: - Ac Units
    public func acActualFlights(with body: AcActualFlight, completion: @escaping (Result<BaseResponse<AcActualFlightResponse>, BaseError>) -> Void) -> Cancelable {
        let path = ServicePath.getAcActualFlights
        return execute(path: path, with: .post, body: body, parameters: nil, completion: completion)
    }
    
    public func pnMaster(with body: PnMaster, completion: @escaping (Result<BaseResponse<PnMasterResponse>, BaseError>) -> Void) -> Cancelable {
        let path = ServicePath.pnMaster
        return execute(path: path, with: .post, body: body, parameters: nil, completion: completion)
    }
    
    public func inventoryDetails(with body: InventoryDetail, completion: @escaping (Result<BaseResponse<InventoryDetailResponse>, BaseError>) -> Void) -> Cancelable {
        let path = ServicePath.inventoryDetails
        return execute(path: path, with: .post, body: body, parameters: nil, completion: completion)
    }
    
    public func inventorySummaries(with body: InventoryDetail, completion: @escaping (Result<BaseResponse<InventorySummaryResponse>, BaseError>) -> Void) -> Cancelable {
        let path = ServicePath.inventorySummaries
        return execute(path: path, with: .post, body: body, parameters: nil, completion: completion)
    }
    
    public func inventoryControls(with body: InventoryControl, completion: @escaping (Result<BaseResponse<InventoryControlResponse>, BaseError>) -> Void) -> Cancelable {
        let path = ServicePath.inventoryControls
        return execute(path: path, with: .post, body: body, parameters: nil, completion: completion)
    }
}


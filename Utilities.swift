class Utilities {
    static func getPrintableObjectOf(input:Any) -> [String:String]? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: input, options: .prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            
            let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
            // here "decoded" is of type `Any`, decoded from JSON data
            
            // you can now cast it with the right type
            if let dictFromJSON = decoded as? [String:String] {
                print(dictFromJSON)
                return dictFromJSON
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}

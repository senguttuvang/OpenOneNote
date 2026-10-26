import Foundation
import SwiftSoup

public enum HTMLAssetRewriter {
    public static func rewrite(_ html: String, resource: (String, Bool) throws -> String) throws -> String {
        let document = try SwiftSoup.parseBodyFragment(html)
        for element in try document.select("img[src], object[data]").array() {
            let image = element.tagName() == "img"
            let key = image ? "src" : "data"
            try element.attr(key, resource(element.attr(key), image))
        }
        return try document.body()?.html() ?? ""
    }
}

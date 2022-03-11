import TPInAppReceipt
import StoreKit

@objc(QAToolkitReceiptBridge)
class QAToolkitReceiptBridge: NSObject {

    @objc(refreshWithCompletion:)
    static func refresh(completion: @escaping ((Error?) -> ())) {
        InAppReceipt.refresh(completion: completion)
    }

    @objc(info)
    static func info() -> NSArray? {

        guard let receipt = try? InAppReceipt.localReceipt() else {
            return nil
        }

        let dateFormatter: ISO8601DateFormatter = {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = .withInternetDateTime
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            return formatter
        }()

        var info = [[String: Any]]()

        info.append([
            "title": "ReceiptInfo",
            "value": """
            Bundle Id: \(receipt.bundleIdentifier),
            App Version: \(receipt.appVersion),
            Orig. App Version: \(receipt.originalAppVersion),
            Created: \(receipt.creationDate),
            Expires: \(receipt.expirationDate != nil ? dateFormatter.string(from: receipt.expirationDate!) : "-"),
"""

        ])

        receipt.purchases.sorted(by: { $0.purchaseDate < $1.purchaseDate }).enumerated().forEach({

            let searchable: [String] = [
                dateFormatter.string(from: $0.element.purchaseDate),
                $0.element.transactionIdentifier,
                $0.element.originalTransactionIdentifier,
                $0.element.productIdentifier,
                dateFormatter.string(from: $0.element.purchaseDate),
                $0.element.subscriptionExpirationDate != nil ? dateFormatter.string(from: $0.element.subscriptionExpirationDate!) : "",
                $0.element.webOrderLineItemID != nil ? String($0.element.webOrderLineItemID!) : "",
            ].filter({ !$0.isEmpty })

            info.append([
                "id": "inapp",
                "date": dateFormatter.string(from: $0.element.purchaseDate),
                "title": "InAppPurchase #\($0.offset + 1)",
                "value": """
                ID: \($0.element.transactionIdentifier)
                OrigID: \($0.element.originalTransactionIdentifier)
                isTrial: \($0.element.subscriptionTrialPeriod)
                isIntro: \($0.element.subscriptionIntroductoryPricePeriod)
                ProductID: \($0.element.productIdentifier)
                Quantity: \($0.element.quantity)
                Purchased: \(dateFormatter.string(from: $0.element.purchaseDate))
                Expires: \($0.element.isRenewableSubscription ? ($0.element.subscriptionExpirationDate != nil ? dateFormatter.string(from: $0.element.subscriptionExpirationDate!) : "-") : "-")
                Canceled: \($0.element.isRenewableSubscription ? ($0.element.cancellationDate != nil ? "\($0.element.cancellationDate!)" : "-") : "-")
                WebOrderLineItemId: \($0.element.webOrderLineItemID != nil ? String($0.element.webOrderLineItemID!) : "-")
""",
                "searchable": searchable,
            ])

        })

        return info.map({ item -> [String: Any] in

            var r: [String: Any] = [
                "title": item["title"]!,
            ]

            if let value = item["id"] {
                r["id"] = value
            }
            
            if let value = item["date"] {
                r["date"] = value
            }

            if let value = item["searchable"] {
                r["searchable"] = value
            }

            if let value = item["value"] as? String {
                r["value"] = value
                    .components(separatedBy: "\n")
                    .map({ "  " + $0.trimmingCharacters(in: .whitespacesAndNewlines) })
                    .joined(separator: "\n")
            }

            return r
        }) as NSArray
    }
}


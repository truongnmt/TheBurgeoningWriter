/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Intents
import CoreSpotlight
import MobileCoreServices

public let kNewArticleActivityType = "com.razeware.NewArticle"

public class Article {
  public let title: String
  public let content: String
  public let published: Bool
  
  // Making shortcut for writing new article
  public static func newArticleShortcut(with thumbnail: UIImage?) -> NSUserActivity {
    let activity = NSUserActivity(activityType: kNewArticleActivityType)
    activity.persistentIdentifier = NSUserActivityPersistentIdentifier(kNewArticleActivityType)
    
    activity.isEligibleForSearch = true
    activity.isEligibleForPrediction = true
    
    // Shown at frontend (when pull down from search, appear at spotlight)
    let attributes = CSSearchableItemAttributeSet(itemContentType: kUTTypeItem as String)
    
    // Title
    activity.title = "Logging a new transaction"
    
    // Subtitle
    attributes.contentDescription = "Don't ask yourself where is all my money again!"
    
    // Thumbnail
    attributes.thumbnailData = thumbnail?.jpegData(compressionQuality: 1.0)
    
    // Suggested Phrase
    activity.suggestedInvocationPhrase = "I have a new transaction!"
    
    activity.contentAttributeSet = attributes
    return activity
  }
  
  // Create an intent for publishing articles
  public func donatePublishIntent() {
    let intent = PostArticleIntent()
    intent.article = INObject(identifier: self.title, display: self.title)
    intent.publishDate = formattedDate()
    
    let interaction = INInteraction(intent: intent, response: nil)
    
    interaction.donate { error in
      if let error = error {
        print("Donating intent failed with error \(error)")
      }
    }
  }
  
  // MARK: - Init
  public init(title: String, content: String, published: Bool) {
    self.title = title
    self.content = content
    self.published = published
  }
  
  // MARK: - Helpers
  public func toData() -> Data? {
    let dict = ["title": title, "content": content, "published": published] as [String: Any]
    let data = try? NSKeyedArchiver.archivedData(withRootObject: dict, requiringSecureCoding: false)
    return data
  }
  
  public func formattedDate() -> String {
    let date = Date()
    let formatter = DateFormatter()
    
    formatter.dateFormat = "MM/dd/yyyy"
    let result = formatter.string(from: date)
    
    return result
  }
}

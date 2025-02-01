import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var favoriteButton: UIButton!
    @IBOutlet private weak var podcastTitleLabel: UILabel!
    @IBOutlet private weak var podcastBodyLabel: UILabel!
    
    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        podcastTitleLabel.text = content.subtitle
        podcastBodyLabel.text = content.body

        guard let attachment = content.attachments.first,
              attachment.url.startAccessingSecurityScopedResource() else {
            return
        }

        let fileURLString = attachment.url

        guard let imageData = try? Data(contentsOf: fileURLString),
              let image = UIImage(data: imageData) else {
            attachment.url.stopAccessingSecurityScopedResource()
            return
        }

        imageView.image = image
        attachment.url.stopAccessingSecurityScopedResource()
    }

    @IBAction private func favoriteButtonTapped(_ sender: Any) {
        favoriteButton.isSelected.toggle()
        let symbolName = favoriteButton.isSelected ? "star.fill" : "star"
        let image = UIImage(systemName: symbolName)
        favoriteButton.setBackgroundImage(image, for: .normal)
    }

    @IBAction private func playButtonTapped(_ sender: Any) {
        extensionContext?.performNotificationDefaultAction()
    }


}

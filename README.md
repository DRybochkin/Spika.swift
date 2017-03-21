В базовом проекте много отклонений от MVC и всякого разного, по мере обнаружения буду переделывать. 
Цель быстро перевести на swift и запустить чат

# Spika iOS module

## Example project compile instruction

- Clone project to your computer.
- Go to iOS folder
- Run pod install (if you are not familiar with cocoapods visit https://cocoapods.org/)
- Open Spika.xcworkspace with Xcode
- Build and run

## Integrate in new or existing project instruction

### Only for new project:
- Create new single view application
- Exit xcode
- Run pod init (if you are not familiar with cocoapods visit https://cocoapods.org/)

### Continued for exististing projects:
- Open Podfile in Spika/iOS folder & copy/paste pod dependancies to your Podfile in root of project
- Run pod install
- Open YourProjectName.xcworkspace with Xcode
- Drag and drop Spika/iOS/Spika folder to your project in Xcode & check Copy items if needed option
- Open Info.plist file in your project and add new key NSAppTransportSecurity/NSAllowsArbitraryLoads = YES (temporarily to allow read from non https urls)

##To instantiate and show CSChatViewController use this code:

```
CSCustomConfig.sharedInstance.server_url = serverTextField.text
        CSCustomConfig.sharedInstance.socket_url = socketTextField.text
        let parameters: [AnyHashable: Any] = [paramUserID: "your_user_id", paramName: "your_user_name", paramAvatarURL: "http://url_to_your_avatar.jpg", paramRoomID: "Your_room_id"]
        let viewController = CSChatViewController(parameters: parameters)
        //let navigationController: UINavigationController = UINavigationController(rootViewController: viewController)
        //presentViewController.(navigationController, animated: true, completion: nil)
        _ = navigationController?.pushViewController(viewController, animated: true)
```

<iframe src="https://player.vimeo.com/video/153215431" width="500" height="375" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe> <p><a href="https://vimeo.com/153215431">spika ios demo</a> from <a href="https://vimeo.com/user48281194">Clover Studio</a> on <a href="https://vimeo.com">Vimeo</a>.</p>

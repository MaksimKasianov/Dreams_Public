import UIKit
import CoreData
import Combine
import SwiftOpenAI

class AssistantChatVС: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextView: ChatTextView!
    @IBOutlet weak var sendBt: LoaderButton!
    @IBOutlet weak var messageHelp: UIView!
    @IBOutlet weak var onlineIndecator: UIImageView!
    
    var chatStreamProvider = AssistantChatStreamProvider()
    var messages: [Message] = []
    var cancellables = Set<AnyCancellable>()
    
    var heightConstraint: NSLayoutConstraint!
    var maxHeight = 50.0
    
    var networkMonitor = NetworkMonitor.shared
    var isConnected = false
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkMonitor.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.isConnected = isConnected
                
                if isConnected == true {
                    self?.onlineIndecator.image = UIImage(named: "indicator-online")
                } else {
                    self?.onlineIndecator.image = UIImage(named: "indicator-offline")
                }
            }
            .store(in: &cancellables)
        
        networkMonitor.startMonitoring()
        
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.layer.shadowOpacity = 0
        
        topView.addShadow(y: -2)
       
        bottomView.addShadow(y: 2)
        
        messageHelp.layer.cornerRadius = 12
        messageHelp.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        chatStreamProvider.$messages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] messages in
                self?.messages = messages
                
                self?.tableView.reloadData()
                self?.tableView.scrollToBottom(count: messages.count)
                
                if messages.last?.role == MessageParameter.Role.assistant.rawValue {
                    self?.sendBt.isLoading = false
                }
            }
            .store(in: &cancellables)
        
        chatStreamProvider.$threadId
            .sink { [weak self] threadId in
                if threadId == nil {
                    self?.chatStreamProvider.createThread()
                }
            }
            .store(in: &cancellables)
        
        setupMessageTextView()
    }
    
    func setupMessageTextView() {
        messageTextView.delegate = self
        messageTextView.updateText("")
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        if let userInfo = notification.userInfo {
            let animationDuration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
            let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            
            let keyBoardRect = view.convert(keyboardScreenEndFrame, from: nil)
            
            UIView.animate(withDuration: animationDuration, delay: 0, options: .beginFromCurrentState,
                           animations: {
                if notification.name == UIResponder.keyboardWillHideNotification {
                    self.bottomConstraint.constant = 48
                } else {
                    self.bottomConstraint.constant = keyBoardRect.size.height - self.view.safeAreaInsets.bottom + 16
                }
                self.view.layoutIfNeeded()
            }, completion: {_ in
                if notification.name == UIResponder.keyboardWillHideNotification {
                    
                } else {
                    self.tableView.scrollToBottom(count: self.messages.count)
                }
            })
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.layer.shadowOpacity = 0
    
        if let button = (tabBarController?.tabBar as? CustomizedTabBar)?.middleBtn {
            button.superview?.isUserInteractionEnabled = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if messageTextView.isFirstResponder {
            messageTextView.resignFirstResponder()
        }
    }
    
    @IBAction func sendButtonTapped(_ sender: LoaderButton) {
        guard let text = messageTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        
        if self.isConnected == false {
            view.makeToast("No internet connection", position: .top)
            return
        } else if sender.isLoading || text.isEmpty {
            return
        }
        
        sender.isLoading = true
        self.messageTextView.updateText("")
        
        if let threadId = chatStreamProvider.threadId {
            Task {
                do {
                    try await chatStreamProvider.createMessage(threadId: threadId, content: text)
                    
                    try await chatStreamProvider.createRunAndStreamMessage(threadId: threadId, parameters: .init(assistantID: Assistant.chat.rawValue))
                } catch {
                }
            }
        } else {
            print("Thread ID not available.")
        }
    }
    
    @IBAction func menuBt(_ sender: UIBarButtonItem) {
        self.showSettindsVC()
    }
}

extension UITableView {
    func scrollToBottom(count: Int) {
        if (count - 1) > 0 {
            let indexPath = IndexPath(row: (count - 1), section: 0)
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

extension AssistantChatVС: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        let role = (message.role == "assistant") ? "assistantCell" : "userCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: role, for: indexPath) as! MessageCell
        
        cell.configure(with: message)
        return cell
    }
}

extension AssistantChatVС: UITextViewDelegate {
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}


import SpriteKit

enum MSButtonNodeState {
    case MSButtonNodeStateActive, MSButtonNodeStateSelected, MSButtonNodeStateHidden
}
//mm
class MSButtonNode: SKSpriteNode {
    //test
    /* Setup a dummy action closure */
    var selectedHandler: () -> Void = { print("No button action set") }
    var selectedHandlers: () -> Void = { print("No button action set") }
    /* Button state management */
    var state: MSButtonNodeState = .MSButtonNodeStateActive {
        didSet {
            switch state {
            case .MSButtonNodeStateActive:
                /* Enable touch */
                self.isUserInteractionEnabled = true
                
                /* Visible */
          //      self.alpha = 1
                break
            case .MSButtonNodeStateSelected:
                /* Semi transparent */
                self.alpha = 0.7
                break
            case .MSButtonNodeStateHidden:
                /* Disable touch */
                self.isUserInteractionEnabled = false
                
                /* Hide */
         //       self.alpha = 0
                break
            }
        }
    }
    
    /* Support for NSKeyedArchiver (loading objects from SK Scene Editor */
    required init?(coder aDecoder: NSCoder) {
        
        /* Call parent initializer e.g. SKSpriteNode */
        super.init(coder: aDecoder)
        
        /* Enable touch on button node */
        self.isUserInteractionEnabled = true
    }
    
    // MARK: - Touch handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .MSButtonNodeStateSelected
        selectedHandler()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedHandlers()
        state = .MSButtonNodeStateActive
    }
    
}

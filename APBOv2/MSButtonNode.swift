
import SpriteKit

enum MSButtonNodeState {
    case MSButtonNodeStateActive, MSButtonNodeStateSelected, MSButtonNodeStateHidden, MSButtonStopAlphaChanges
}
//mm
class MSButtonNode: SKSpriteNode {
    var isAlphaSwitching = true
    
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
                if isAlphaSwitching{
                    self.alpha = 0.7
                }
                break
            case .MSButtonNodeStateHidden:
                /* Disable touch */
                self.isUserInteractionEnabled = false
                
                /* Hide */
         //       self.alpha = 0
                break
            case .MSButtonStopAlphaChanges:
                isAlphaSwitching = false
                
            }
        }
    }
    override init(texture texture: SKTexture!, color color: UIColor!, size size: CGSize)
    {
        super.init(texture: texture, color: color, size: size)
        isUserInteractionEnabled = true
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
        if self.alpha != 0 {
            selectedHandlers()
        }
        state = .MSButtonNodeStateActive
    }
    
}

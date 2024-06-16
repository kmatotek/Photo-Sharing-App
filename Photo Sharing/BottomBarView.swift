import UIKit

class BottomBarView: UIView {

    // Buttons
    private var buttons: [UIButton] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        // Set background color with normalized RGB values
        backgroundColor = UIColor(red: 101/255.0, green: 77/255.0, blue: 117/255.0, alpha: 1.0)

        setupButtons()
    }

    private func setupButtons() {
        let buttonTitles = ["x", "x", "x", "x"]
        for title in buttonTitles {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
            buttons.append(button)
            addSubview(button)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let buttonWidth = frame.size.width / CGFloat(buttons.count)
        let buttonHeight = frame.size.height

        for (index, button) in buttons.enumerated() {
            button.frame = CGRect(x: CGFloat(index) * buttonWidth, y: 0, width: buttonWidth, height: buttonHeight)
        }
    }
}

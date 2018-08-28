//
//  ViewController.swift
//  HelloRxSwitf
//
//  Created by chaowenwang on 2018/7/15.
//  Copyright © 2018年 chaowenwang. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var usernameValidOutlet: UILabel!
    
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidOutlet: UILabel!
    
    @IBOutlet weak var loginOutlet: UIButton!
    
    static let minUsernameLength = 5
    static let minPasswordLength = 5
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let usernameValid = usernameOutlet.rx.text.orEmpty
            .map{ $0.count >= ViewController.minUsernameLength }.share(replay: 1)
        usernameValid.bind(to: passwordOutlet.rx.isEnabled).disposed(by: disposeBag)
        usernameValid.bind(to: usernameValidOutlet.rx.isHidden).disposed(by: disposeBag)
        
        let passwordValid = passwordOutlet.rx.text.orEmpty
            .map{ $0.count >= ViewController.minPasswordLength }.share(replay: 1)
        passwordValid.bind(to: passwordValidOutlet.rx.isHidden).disposed(by: disposeBag)
        
        let loginValid = Observable.combineLatest(usernameValid,passwordValid){ $0 && $1 }.share(replay: 1)
        loginValid.bind(to: loginOutlet.rx.isEnabled).disposed(by: disposeBag)
        
        loginOutlet.rx.tap.subscribe(onNext: { [weak self] in self?.showAlert() }).disposed(by: disposeBag)
        
    }

    func showAlert() {
        let alert = UIAlertController(title: "Hello", message: "RxSwift is so cool", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }


}

//share(replay: 1) 是用来做什么的？
//我们用 usernameValid 来控制用户名提示语是否隐藏以及密码输入框是否可用。shareReplay 就是让他们共享这一个源，而不是为他们单独创建新的源。这样可以减少不必要的开支。
//disposed(by: disposeBag) 是用来做什么的？
//和我们所熟悉的对象一样，每一个绑定也是有生命周期的。并且这个绑定是可以被清除的。disposed(by: disposeBag)就是将绑定的生命周期交给 disposeBag 来管理。当 disposeBag 被释放的时候，那么里面尚未清除的绑定也就被清除了。这就相当于是在用 ARC 来管理绑定的生命周期。


//
//  UserListCell.swift
//  BinaryBlitzTest
//
//  Created by Алексей on 26.09.16.
//
//

import UIKit
import SnapKit

class UserListCell: UITableViewCell {

    var nameLabel = UILabel()
    
    var emailLabel = UILabel()
    
    var avatarView = UIImageView()
    
    var avatarImage: UIImage? = nil {
        didSet {
            self.avatarView.image = avatarImage
            self.layoutIfNeeded()
            self.updateConstraintsIfNeeded()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(avatarView)
        
        avatarView.snp.makeConstraints { make in
            make.left.equalTo(self).offset(10)
            make.height.equalTo(self)
            make.width.lessThanOrEqualTo(40)
        }
        
        avatarView.contentMode = .scaleAspectFit
        
        self.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarView.snp.right).offset(10)
            make.height.equalTo(self).dividedBy(2)
        }
        
        emailLabel.textColor = UIColor.gray
        emailLabel.font = UIFont.systemFont(ofSize: 14)

        self.addSubview(emailLabel)
        
        emailLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarView.snp.right).offset(10)
            make.top.equalTo(nameLabel.snp.bottom)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.avatarImage = nil
    }
}

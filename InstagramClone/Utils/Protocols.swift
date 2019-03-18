//
//  Protocols.swift
//  InstagramClone
//
//  Created by Egor Tkachenko on 17/03/2019.
//  Copyright © 2019 ET. All rights reserved.
//

protocol UserProfileHeaderDelegate {
    func handleEditFollowTapped(for header: UserProfileHeader)
    func setUserStats(for header: UserProfileHeader)
}

//
//  OnboardingViewModel.swift
//  FlexSight
//

import Observation

@MainActor
@Observable
final class OnboardingViewModel {
    var currentPage: OnboardingPage = .welcome

    func advance() {
        currentPage = .overview
    }
}

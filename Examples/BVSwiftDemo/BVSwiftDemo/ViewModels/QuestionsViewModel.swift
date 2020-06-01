//
//  QuestionsViewModel.swift
//  BVSwiftDemo
//
//  Created by Balkrishna Singbal on 27/05/20.
//  Copyright © 2020 Bazaarvoice. All rights reserved.
//

import Foundation
import BVSwift

protocol QuestionsViewModelDelegate: class {
    
    func fetchQuestions()
    
    var numberOfSections: Int { get }
    
    var numberOfRows: Int { get }
    
    func questionForRowAtIndexPath(_ indexPath: IndexPath) -> BVQuestion?
    
}

class QuestionsViewModel: ViewModelType {
    
    weak var viewController: QuestionsTableViewControllerDelegate?
    
    weak var coordinator: Coordinator?
    
    private var questions: [BVQuestion]?
}

// MARK:- QuestionsViewModelDelegate
extension QuestionsViewModel: QuestionsViewModelDelegate {
    
    func questionForRowAtIndexPath(_ indexPath: IndexPath) -> BVQuestion? {
        
        guard let question = self.questions?[indexPath.row] else {
            return nil
        }
        
        return question
    }
    
    var numberOfSections: Int {
        return 1
    }
    
    var numberOfRows: Int {
        return self.questions?.count ?? 0
    }
    
    func fetchQuestions() {
        
        guard let delegate = self.viewController else { return }
        
        delegate.showLoadingIndicator()
        
        let questionQuery = BVQuestionQuery(productId: "test1",
                                            limit: 10,
                                            offset: 0)
            .include(.answers)
            .include(.products)
            .filter(((.hasAnswers(true), .equalTo)))
            .configure(ConfigurationManager.sharedInstance.config)
            .handler { [weak self] (response: BVConversationsQueryResponse<BVQuestion>) in
                
                guard let strongSelf = self else { return }
                
                delegate.hideLoadingIndicator()
                
                if case .failure(let error) = response {
                    print(error)
                    // TODO:- show alert
                    return
                }
                
                guard case let .success(_, questions) = response else {
                    // TODO:- show alert
                    return
                }
                
                strongSelf.questions = questions
                delegate.reloadTableView()
        }
        
        questionQuery.async()
    }
}
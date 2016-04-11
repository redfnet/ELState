//
//  Store.swift
//  ELState
//
//  Created by Brandon Sneed on 3/27/16.
//  Copyright © 2016 Electrode-iOS. All rights reserved.
//

import Foundation

@objc
public class Store: NSObject {
    public var state: State? {
        get {
            let tempState = _state
            return tempState
        }
    }
    
    public init(state: State, reducer: BaseReducer) {
        self.reducer = reducer
        self._state = state
        super.init()
        
        // Dispatch the InitAction so everyone puts in their default state.
        dispatch(InitAction())
    }
    
    public func subscribe(s: BaseSubscriber) {
        listeners.append(s)
        if let currentState = state {
            s._newState(currentState, store: self)
        }
    }
    
    public func unsubscribe(s: BaseSubscriber) {
        //listeners = listeners.filter({ $0 != s })
    }
    
    public func dispatch(action: ActionType) {
        // this should only catch if a reducer attempts to dispatch an action.
        if isDispatching {
            assertionFailure("Reducers cannot dispatch actions!")
            return
        }
        
        // go into dispatch mode.
        isDispatching = true
        
        // get the state
        _state = reducer._handleAction(action, state: state)
        // dispatch it to all subscribers.
        if let state = state {
            let currentListeners = listeners
            currentListeners.forEach {
                $0._newState(state, store: self)
            }
        }
        
        // we're done, turn it off
        isDispatching = false
    }
    
    private var _state: State? = nil
    // TODO: Make this atomic?
    private var isDispatching: Bool = false
    
    // we want a weak hold on any listeners in case they forget
    // to unsubscribe.
    private var listeners = [BaseSubscriber]()//NSHashTable.weakObjectsHashTable()
    // the main reducer for the application.
    private var reducer: BaseReducer

}
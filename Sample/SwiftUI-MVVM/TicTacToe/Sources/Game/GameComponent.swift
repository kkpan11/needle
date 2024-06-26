//
//  Copyright (c) 2018. Uber Technologies
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import NeedleFoundation
import SwiftUI

protocol GameDependency: Dependency {
    var mutableScoreStream: MutableScoreStream { get }
    var playersStream: PlayersStream { get }
}

class GameComponent: Component<GameDependency>, GameBuilder {
    
    var gameViewModel: GameViewModel {
        GameViewModel(
            mutableScoreStream: dependency.mutableScoreStream,
            playersStream: dependency.playersStream
        )
    }
    
    var gameView: AnyView {
        AnyView(
            GameView(
                viewModel: gameViewModel,
                scoreSheetBuilder: scoreSheetBuilder
            )
        )
    }

    var scoreSheetBuilder: ScoreSheetBuilder {
        ScoreSheetComponent(parent: self)
    }

    // This should not be used as the provider for GameDependency.
    var mutableScoreStream: MutableScoreStream {
        ScoreStreamImpl()
    }
}

// Use a builder protocol to allow mocking for unit tests. At the same time,
// this allows GameView to be initialized lazily.
protocol GameBuilder {
    var gameView: AnyView { get }
}

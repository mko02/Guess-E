## Instructions (Post-demo)
Please go to the **to-publish** branch for newest changes made to the project. We will not touch main for now to avoid interfering with the original version.

Go to 'Issues' to find some tasks to work on. Will be updated with more as we progress.

In the multiple rounds version of this game, we are manipulating the shared state with only one state object rather than two (as in the one round case). This object is the hostState, which only the host can manipulate.

In the case of shared state changed by host:
1. Host performs changes locally.
2. Host calls sync to deliver the updated state to all active players.

In the case of shared state changed by players:
1. Player uses pool.send(message, host), where message is one of the structs that implement the Message protocol.
2. That message contains instructions for the host to follow.
3. Host propagates those changes towards all players.


## Project Overview (Pre-demo)

The project is broken down into *stages*. These stages are: 
1. Standalone UI / Screens
	- We first create standalone screens but don't connect them to other screen or any external state. This will allow us to take care of UI first and then tie it all together while making sure we can test the app going forward.
2. Connectivity API:
	- We need a way to talk to other devices. We've explored the connectivity API but we want something more high-level that will allow us to send arbitrary message to other clients.
	- This means creating a wrapper library for the connectivity API
	- Once we have that, we can send discrete messages between clients, which will allow us to synchronize the game state between multiple clients
3. Putting it all together.
	- Once we have the state synchronized, we can connect the state to the UI we created in **stage 1**
	- This means creating a game state object, passing it in the view hierarchy, and reading the appropriate data.
	- This also means that any action that modifies the state will also have to send a message to the correct devices, so they can update their state and present the correct data
	- Finally, the order of the screen is also a piece of state. This means that at this stage we will use `NavigationStack` that will allow us to present the appropriate screen to the user and finally tie all the UI/Screens together

## Standalone UI/Screens

**Due next Thursday meeting April 6th**

*Based on this [Figma](https://www.figma.com/file/PTieKVikWsvMR5B2uqDilP/Guess-E-Design?node-id=514-3&t=9RXTDfSkLcOcpzTE-0)*

Each of you will be assigned a screen to implement. 

**If you encounter any issues, please ask for help.** 

For now, we will create screens with *stub* data. For example, if the Figma design contains a button, you will use `Button` with a stub title and empty action. Later, in stage 3, we will replace these stubs with actual data. For now, `Button("Press me") { }` will do just fine.
Please, try to build screens as close as possible to the design in Figma, but don't spend too much time, especially right now that the design is not finalized, getting it pixel-perfect. As long as buttons work and text is in the right place, it should suffice. 
You will find screen names at the top left corner of the screen thumbnail in Figma. Then, look up your screen assignment below, based on your github username, and start *creating 👷‍♂️🧑‍💻✨🤤*

Landing -> laurennpak <br>
Join Session -> nac5504 <br>
Create Session -> mko02<br>
Session Waiting -> sts04038<br>
Player Order -> noahsadir<br>
Image Creator -> matheweon<br>
Waiting for Image -> ghmcguire<br>
Waiting for Guesses -> TBD<br>
Guessing Image -> TBD<br>
Ranking Guesses -> Aziz<br>
Waiting for Ranking -> Aziz<br>
Ranking Results -> Aziz<br>

## Connectivity API

We made a wrapper around the connectivity API that makes it easier (hopefully) to work with the API. There is a `MultipeerManager` that handles advertising and browsing, and there is a `MessagePool` that you can use to send messages to the host and broadcast messages from the host to all the player. Specifically, 
`MultipeerManager`: 
1. `startAdvertising()` starts MC advertising, this is called by the players on `onAppear`
2. `startBrowsing()` starts MC browsing for nearby peers, called by the game host (GH).
3. `stopAdvertising()` / `stopBrowsing()` stop the respective activities, called from `onDisappear`

In the current version, the GH will be continuously looking for peers and automatically connect to them. The players that get an invitation from a host would automatically accept. So, 
1. GH → Player (invitation)
2. Player → GH (accept invitation)
Once the player is connected, it gets a list of connected GHs and it displays it in the `JoinSession` screen. Upon selecting a GH, the player sends a `RequestToPlay` message, using the `MessagePool` API. If the GH accepts the request from the player, the player can move on to the `SessionWaiting` screen. So, 

1. Player →(request to play) GH 
2. GH →(response) Player 
	1. if accepted: move to the next screen
	2. go back to the previous screen

Speaking of the `MessagPool`, it has two public functions `send()` and `sync()`. **Players must not call sync**. The syncing is reserved for the GH to synchronized the shared state. We have a server-client model where the GH is the server and the players are the clients. This means the players cannot directly communicate with other clients, and the only wait to do it is through the GH. 
The players can send messages to the GH to alter the shared state or have the host do something. For that, you need to define a new message type, conforming to the `Message` protocol, as well as the message type in the `MessageType` enum. **Do not forget to make a new entry to the `typeMap` property of the `MessageType`**. That property is essential to decoding and properly handling the messages. 

Now is the time to put the screens together. We are not entirely sure how to divide the the tasks, so I think we are going to just code and see what happens. But if I were to break it down by screen, it would look something like this:

#### Landing: 
1. Create Game: → Create Session
2. Join Game: → Join Session

#### Join Session
1. {SM} Request to Join (Game)
	- Approve: → Session Waiting
	- Deny: UI to reflect denial

#### Session Waiting
1. {RM} GameState
2. {RM} Game is starting: → PlayerOrder

#### Player Order
1. {RM} Game has started: → Waiting For Image

#### Waiting For Image
1. {RM}  “Aziz is thinking” → “DALL-E is thinking”
2. {RM} Image is created: → Guessing Image

#### Guessing Image
1. render the image (use the url from the shared state and `AsyncImage`)
2. once “Done” is pressed
	1. send the guess to the host 
	2. `pool.send(MadeAGuess(guess: "Bear riding a shark"), host: state.host)`

2 things: 
1. Update the state for guesses
2. Move the player → `WaitingForRanking`
3. Once all the guesses have been made, move the host to the `RankingGuesses` 
```swift
struct MadeAGuess: Message { 
	let guess: String
	/// Called on the host!!!
	func apply(from peer: Peer, to state: GameStaet) { 
		state.sync { 
			// step 2 from above
			state.currentScreen[peer] = .waitingForRanking
			// step 1 from above
			state.guesses[peer] = guess
			// step 3 
			// hint: rememver that the dict will have nil values for everyone 
			// that hasn't made a guess
			if guesses have been made { 
				state.currenScreen[host] = .ranking
			}
		}
	}
}
```

#### Image Creator
1. Make API call to DALL-E and spin
	1. Optionally, change the state from “Aziz is thinking” → “DALL-E is thinking”
	2. Disable the timer
2. Once the API call returns with an image url
	1. set image url on the shared state
	2. change current screen for everyone → Guessing Image
	3. sync


#### Ranking Guesses
1. Rank them
2. Once “Done” is pressed
	1. send the ranking to all the players
		1. Hint. use the `Shared` struct 
	2. Move each player to the `RankingResults`


#### Waiting for Ranking
1. {RM} Guesses (\[peer: guess\])
2. {RM} Produced rankings (\[peer: guess\]): → Ranking Results

## Fixing bugs
ToDo: 
- [ ] Use actual name from the Landing Page
- [ ] `PlayerOrder` view change the stub names to actual names, kind of depends on #1 (Maksim)
- [ ] `JoinLocalSession`  (Noah)
	1. change the horizontal padding 
	2. change the tint of the selected session
		1. White with 0.68 opacity
	3. change the number of players in the session 
	4. remove the cell separators
	5. UI (spinner) to wait for request to be approved (next to person icon)
		1. “Join Game” disabled until either rejected or accepted 
- [ ] `ImageCreator` (Gabe)
- [ ] `WaitingForGuesses` (Gabe)
- [ ] `CreateSessionView` (Alena + Maksim)
	1. Dark mode support
	2. align buttons
	3. Change description of state enums 
	4. functionality to kick people out of session (bigger button)
	5. foreground color on text (white)
	6. segmented control tint color (hack UISegmentedControl.apperarance() )
	7. Don’t let the game to start unless (John)
		1. .disabled(true if … )
		2. There are at least one player
		3. All the players are in the `Ready` state
- [ ] Image Creator View
	1. Change everything according to Figma
- [ ] Merge `WaitingForImage` and `WaitingForGuesses`
- [ ] Bug when all gueses are made, host doesnt move to → `RankingGuesses` (Maks)
- [ ] Restart the game (Maks)
- [ ] Timers (Nick)

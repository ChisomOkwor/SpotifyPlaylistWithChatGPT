
import SwiftUI

struct ContentView: View {
    @State private var userInput: String = ""
    @State private var moodResponse: String = ""
    @State private var isStartedAnimatedMoodResponse:Bool = false
    @State private var clearableViewState: Bool = false

    @State private var songs: [Song] = [] // Define a Song struct with name, image, and Spotify URL properties
    @State private var profileImage: Image? = Image("your_profile_image")
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: 1) {
                HStack {
                    NavigationLink(destination: LandingPage()){
                        Image(systemName: "arrow.left.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding()
                            .foregroundColor(.green)
                    }
                    Spacer()
                }
                    HStack(spacing:1) {
                        if let profileImage = profileImage {
                            NavigationLink(destination: SettingsView(profileImage: $profileImage)) {
                                profileImage
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                    .padding()
                            }
                        }
                        Text("Let's Start Your \(timeOfDay()) Mood Mix")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .offset(x:-15)
                    }
                Spacer()
                Spacer()
                Spacer()
                HStack(spacing:-7){
                    ZStack(alignment: .topLeading) {
                                   TextEditor(text: $userInput)
                                       .padding(5)
                                       .frame(height: 80)
                                       .frame(maxWidth: .infinity)
                                       .background(
                                           RoundedRectangle(cornerRadius: 10)
                                               .stroke(Color.green, lineWidth: 1)
                                       )
                                       .padding(.leading, 15)

                                   if userInput.isEmpty {
                                       Text("\(emoji()) How are you feeling today?")
                                           .foregroundColor(.gray)
                                           .padding(8)
                                           .offset(x: 30, y: 8)
                                   }
                               }
                    Button(action: {
                        // Call the ChatGPT API and update moodResponse and songs
                        // Implement your API calls and logic here
                        moodResponse = ""
                        songs = []
                        simulateAPIResponse()
                    }) {
                        Image(systemName: "paperplane.fill") // Use a paper plane icon or any other send icon
                                .resizable()
                                .frame(width: 10, height: 10)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.green) // Set the send button background color
                                .clipShape(Circle())
                                .offset(x: -20)

                        }
                    Spacer()
                    Spacer()
                    Spacer()
                }
                    HStack {
                        Image(moodResponse.isEmpty ? "" : "moodify")
                            .resizable()
                            .frame(width: 120, height: 60)
                            .padding()
                        Spacer()
                        
                    }
                TypeWriterView(text:$moodResponse, speed: 0.03, isStarted: $isStartedAnimatedMoodResponse).offset(y:-30)
                    
                    NavigationView{
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(), count: 1), spacing: 5) {
                                ForEach(songs, id: \.id) { song in
                                    // Display cute-looking cards with song details
                                    // Customize the SongCard view based on your design preferences
                                    SongCard(song: song)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .frame(alignment: .leading)
                                    
                                }
                            }
                        }
                    }
            }
            .background(Image("your_background_image").resizable().scaledToFill())
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    // Helper function to simulate API response
    func simulateAPIResponse() {
        print("simulateAPIResponse")
        let chatGPTService = ChatGPTService()
        chatGPTService.getChatGPTResponse(userInput: userInput) { result in
            switch result {
            case .success(let response):
                // Handle the successful response here
                let (firstSentence, chat_gpt_songs) = parseChatGPTContent(response.choices[0].message.content)
                moodResponse = firstSentence
                                isStartedAnimatedMoodResponse.toggle()
                fetchSpotifySongs(chat_gpt_songs)
                print(firstSentence)
                ScrollView {
                    LazyVStack {
                        ForEach(songs, id: \.id) { song in
                            SongCard(song: song)
                        }
                    }
                }
                
            case .failure(let error):
                // Handle the error here
                print("Error not sucessful: \(error.localizedDescription)")
            }
            
        }
    }
    
    func fetchSpotifySongs(_ chat_gpt_songs: [String]) {
        for song in chat_gpt_songs  {
            print("- \(song)")
            SpotifyService.fetchSpotifyInfo(for: song) { result in
                switch result {
                    
                case .success(let response):
                    let newSong = Song(name: song, image: response.album.images[0].url, spotifyURL: response.external_urls.spotify)
                    
                    DispatchQueue.main.async {
                        songs.append(newSong)
                    }
                   print(newSong)
                   print("Spotify request success")
                    
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    
                }
            }
        }
    }
    
    func parseChatGPTContent(_ content: String) -> (String, [String]) {
        var songs: [String] = []
        var phraseLines: [String] = []

        // Split the content by newline characters
        let lines = content.components(separatedBy: "\n")

        // Iterate through each line
        for line in lines {
            // Check if the line starts with a number followed by a period
            if let range = line.range(of: #"^\d+\."#, options: .regularExpression) {
                let lineWithoutNumber = line[range.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
                songs.append(lineWithoutNumber)
            } else {
                // If the line doesn't start with a number, add it to the phraseLines
                phraseLines.append(line.trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }

        // Combine the remaining lines into a single phrase with reduced spacing
        let phrase = phraseLines.joined(separator: " ")

        return (phrase, songs)
    }


    // Helper function to get the time of day
    func timeOfDay() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12:
            return "Morning"
        case 12..<17:
            return "Afternoon"
        default:
            return "Evening"
        }
    }

    // Helper function to get a random emoji
    func emoji() -> String {
        let emojis = ["😊", "😎", "😍", "🤔", "👀", "🤩"]
        return emojis.randomElement() ?? ""
    }
}


struct SongCard: View {
    var song: Song

    @State private var imageData: Data?

    var body: some View {
        HStack(alignment: .top) {
            if let uiImage = imageData.flatMap(UIImage.init(data:)) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            VStack(alignment: .leading) {
                Text(song.name)
                    .font(.subheadline)
                    .bold()
                    .lineLimit(2)
                
                Link(destination: URL(string: song.spotifyURL)!, label: {
                                    HStack {
                                        Image(systemName: "play.circle.fill")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(.green)
                                        Text("Play on Spotify")
                                            .font(.subheadline)
                                            .foregroundColor(.green)
                                    }
                                    .padding(8)
                                    .background(Color.white)
                                    .cornerRadius(8)
                    })
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
            )
            .frame(width: 280)
        }
        .onAppear {
            loadImage()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .frame(alignment: .leading)
    }

    private func loadImage() {
        guard let url = URL(string: song.image) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                DispatchQueue.main.async {
                    self.imageData = data
                }
            }
        }.resume()
    }
}

struct Song {
    let id = UUID()
    let name: String
    let image: String
    let spotifyURL: String
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}




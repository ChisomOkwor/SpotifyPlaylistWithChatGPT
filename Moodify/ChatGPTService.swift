

//
//  ChatGPTService.swift
//  Moodify
//
//  Created by Chisom on 1/7/24.
//

import Foundation

struct ChatGPTResponse: Decodable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [ChatGPTChoice]
    let usage: ChatGPTUsage
    let systemFingerprint: String?

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case object = "object"
        case created = "created"
        case model = "model"
        case choices = "choices"
        case usage = "usage"
        case systemFingerprint = "system_fingerprint"
    }
}

struct ChatGPTChoice: Decodable {
    let index: Int
    let message: ChatGPTMessage
    let logprobs: [String: String]?
    let finishReason: String

    private enum CodingKeys: String, CodingKey {
        case index = "index"
        case message = "message"
        case finishReason = "finish_reason"
        case logprobs = "logprobs"
    }
}

struct ChatGPTMessage: Decodable {
    let role: String
    let content: String

    private enum CodingKeys: String, CodingKey {
        case role = "role"
        case content = "content"
    }
}

struct ChatGPTUsage: Decodable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int

    private enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}


class ChatGPTService {
    
    private let apiKey = "" // Replace with your actual API key
    private let endpoint = "https://api.openai.com/v1/chat/completions" // Replace with your actual API endpoint

    func getChatGPTResponse(userInput: String, completion: @escaping (Result<ChatGPTResponse, Error>) -> Void) {
        guard let url = URL(string: endpoint) else {
            completion(.failure(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid endpoint"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "user", "content": "Can you provide me with a 20-30 word empathetic response to this text:\(userInput)? and provide me with a numberd list of 10 songs I can listen to."],
            ]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(error))
            print("Error happens here 1")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                print("Error happens here 2")
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid data"])))
                print("Error happens here 3")
                return
            }
                
                do {
                    let decoder = JSONDecoder()
//                                  print(String(data: data, encoding: .utf8) ?? "Invalid data")
                                  let response = try decoder.decode(ChatGPTResponse.self, from: data)
                                  completion(.success(response))
            } catch {
                print("Error happens here 4")

                completion(.failure(error))
            }
        }.resume()
    }
}

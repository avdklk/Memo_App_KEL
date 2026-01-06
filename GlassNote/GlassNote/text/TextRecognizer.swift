//
//  TextRecognizer.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 1/6/26.
//
import Vision
import UIKit

class TextRecognizer {
    
    func recognizeText(from image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage else {
            completion("이미지 변환 실패")
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("에러 발생: \(error)")
                completion("")
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion("")
                return
            }
            
            // 4. 인식된 텍스트들을 하나의 문자열로 합치기
            let recognizedStrings = observations.compactMap { observation in
                // topCandidates(1): 가장 정확도가 높은 후보 1개를 가져옴
                return observation.topCandidates(1).first?.string
            }
            
            let resultText = recognizedStrings.joined(separator: "\n")
            
            // UI 업데이트를 위해 메인 스레드에서 반환
            DispatchQueue.main.async {
                completion(resultText)
            }
        }
        
        // ✨ 설정: 정확도 vs 속도
        request.recognitionLevel = .accurate // .fast로 하면 빠르지만 정확도 낮음
        // ✨ 설정: 언어 (한국어, 영어 우선)
        request.recognitionLanguages = ["ko-KR", "en-US"]
    
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // Vision 작업은 무거우므로 백그라운드에서 실행
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("핸들러 실행 실패: \(error)")
                DispatchQueue.main.async {
                    completion("")
                }
            }
        }
    }
}

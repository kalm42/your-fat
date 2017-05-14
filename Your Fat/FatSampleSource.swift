//
//  FatSampleSource.swift
//  Your Fat
//
//  Created by Kyle Melton on 4/16/17.
//  Copyright © 2017 Kyle Melton. All rights reserved.
//

import Foundation
import HealthKit

class FatSampleSource {
    private let client = HealthKitApiClient()
    private let bodyMassSampleType: HKSampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
    private let bodyFatPercentageSampleType: HKSampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyFatPercentage)!
    
    
    func getSamples( completion: @escaping ([FatMassSample]?, FatSampleSourceError?) -> Void ) {
        print("FatSampleSource: getSamples()")
        
        let to = Date()
        let from = to - TimeLengthInSeconds.oneYear.rawValue
        client.getSamples(from: from, to: to, sampleType: self.bodyMassSampleType){ bodyMassSample, error in
            print("FatSampleSource: getSamples() bodyMass completionHanlder")
            //Check if any samples were returned. If no samples are returned & no error returned, send up nil
            if let bodyMassSample = bodyMassSample {
                //we have body mass samples now get body fat samples.
                
                self.client.getSamples(from: from, to: to, sampleType: self.bodyFatPercentageSampleType) { bodyFatSample, error in
                    print("FatSampleSource: getSamples() bodyFat completionHanlder")
                    DispatchQueue.main.async {
                        if let bodyFatSample = bodyFatSample {
                            //Now we have body fat and bodyMass. Lets do this shit!
                            
                            var bodyFat = [BodyFatPercentageSample]()
                            var bodyMass = [BodyMassSample]()
                            
                            for sample in bodyFatSample {
                                let drop = BodyFatPercentageSample(sample: sample)
                                bodyFat.append(drop)
                            }
                            
                            for sample in bodyMassSample {
                                let drop = BodyMassSample(sample: sample, unit: self.client.getPreferredUnit())
                                bodyMass.append(drop)
                            }
                            let fatMass = self.collate(bodyFat: bodyFat, bodyMass: bodyMass)
                            
                            if !fatMass.isEmpty {
                                completion(fatMass, nil)
                            } else {
                                completion(nil, nil)
                            }
                        } else if error != nil {
                            completion(nil, .HealthKitQueryFailed)
                        }
                        completion(nil, nil)
                    }
                }
            } else if error != nil {
                completion(nil, .HealthKitQueryFailed)
            }
            completion(nil, nil)
        }
    }
    
    func collate(bodyFat: [BodyFatPercentageSample], bodyMass: [BodyMassSample]) -> [FatMassSample] {
        var fatMass = [FatMassSample]()
        if bodyFat.count > bodyMass.count {
            //Body fat has more entries so we will attempt to match each entry to a body mass entry
            for bf in bodyFat {
                let high = bf.date + TimeLengthInSeconds.oneHour.rawValue
                let low = bf.date - TimeLengthInSeconds.oneHour.rawValue
                
                //loop through all entries in bodyMass until a match is found
                for n in 0..<bodyMass.count {
                    if bodyMass[n].date > low && bodyMass[n].date < high { // matches
                        let fms = FatMassSample(bodyMass: bodyMass[n], bodyFatPercentage: bf)
                        fatMass.append(fms)
                        break
                    }
                }
            }
        } else { // either body mass count is greater than or equal to bodyfat count. Ethier way we're okay to use this
            for bm in bodyMass {
                let high = bm.date + TimeLengthInSeconds.oneHour.rawValue
                let low = bm.date - TimeLengthInSeconds.oneHour.rawValue
                
                for n in 0..<bodyFat.count {
                    if bodyFat[n].date > low && bodyFat[n].date < high { // matches
                        let fms = FatMassSample(bodyMass: bm, bodyFatPercentage: bodyFat[n])
                        fatMass.append(fms)
                        break
                    }
                }
            }
        }
        return fatMass
    }
}

enum FatSampleSourceError {
    case HealthKitQueryFailed
}





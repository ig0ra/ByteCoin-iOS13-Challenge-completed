//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateRate(price: String, currency: String)
    func didFailWithError(_ coinManager: CoinManager, error: Error)
}

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "04A2CF19-5961-467B-96F8-8AB102EF8662"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice(for currency: String) {
        let finalURL = "\(baseURL)/\(currency)?apiKey=\(apiKey)"
        
        if let url = URL(string: finalURL) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                
                guard error == nil else {
                    delegate?.didFailWithError(self, error: error!)
                    return
                }
                
                guard let data = data else { return }
                
                if let coinPrice = self.parseJSON(data) {
                        let priceString = String(format: "%.2f", coinPrice)
                        delegate?.didUpdateRate(price: priceString, currency: currency)
                    }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        
        do{
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let rate = Double(decodedData.rate)

            return rate
        } catch {
            delegate?.didFailWithError(self, error: error)
            return nil
        }
    }
}

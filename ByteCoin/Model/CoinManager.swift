//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Mikolaj Korbanek on 27/12/2019.
//  Copyright © 2019 Mikolaj Korbanek. All rights reserved.
//

import Foundation

struct CoinManager {
    
    let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTC"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    var delegate: CoinManagerDelegate?
    
    func getCoinPrice(for currency: String) {
        let requestURL = baseURL + "\(currency)"
        performRequest(for: requestURL)
    }
    
    func performRequest(for urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, urlResponse, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let value = self.parseJSON(safeData) {
                        self.delegate?.didUpdateCurrency(self, value: value)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> Float? {
        do {
            let coinModel = try JSONDecoder().decode(CoinModel.self, from: data)
            return coinModel.ask
        } catch {
            return nil
        }
    }
}

protocol CoinManagerDelegate {
    func didFailWithError(error: Error)
    func didUpdateCurrency(_ coinManager: CoinManager, value: Float)
}

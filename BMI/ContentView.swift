//
//  ContentView.swift
//  BMI
//
//  Created by MAC on 2/11/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var enteredheight: Double = 0.0 // TextFieldに入力した身長の変数
    @State private var enteredweight: Double = 0.0 // TextFieldに入力した体重の変数
    @State private var originalUnit = "meter" // 元(換算する前)の単位を格納する変数
    
    let lengthUnits = ["meter", "centimeter"] // 長さの単位一覧
    private var convertedNumber: Double = 0 // 換算後の数値。
    
    var body: some View {
        NavigationStack {
            Form {
                Section("入力"){
                    HStack{
                        TextField("Original", value: $enteredheight, format: .number)
                            .keyboardType(.numberPad)
                            .padding()
                        
                        Picker("", selection: $originalUnit) {
                            ForEach(lengthUnits, id: \.self) { unit in
                                Text(unit)
                            }
                        }
                    }
                    HStack{
                        TextField("Original", value: $enteredweight, format: .number)
                            .keyboardType(.numberPad)
                            .padding()
                        
                        Text("kg")
                    }
                }
                Section("結果"){
                    HStack{
                        Text(bmiCaluculation(weight: enteredweight,
                                             height: lengthConversion(
                                                oldUnit: originalUnit,
                                                newUnit: "meter",
                                                value: enteredheight)), format: .number)
                    }
                    
                }
                .navigationTitle("BMI計算機")  // 画面上部にタイトルを付ける
                
            }
        }
    }
    
    // 長さの単位変換処理をまとめる
    func lengthConversion(oldUnit: String, newUnit: String, value: Double) -> Double {
        let meterLength = toMeter(lengthUnit: oldUnit, value: value)
        let convertedLength = fromMeterToCentimeter(lengthUnit: newUnit, meterValue: meterLength)
        return convertedLength
    }
    
    // 長さの値をメートルに変換
    func toMeter(lengthUnit: String, value: Double) -> Double{
        switch lengthUnit {
        case "meter":
            return value
        case "centimeter":
            return value / 100
        default:
            return value
        }
    }
    
    // メートルからセンチに変換
    func fromMeterToCentimeter(lengthUnit: String, meterValue: Double) -> Double {
        switch lengthUnit {
        case "meter":
            return meterValue
        case "centimeter":
            return meterValue * 100
        default:
            return meterValue
        }
    }
    
    func bmiCaluculation(weight: Double, height: Double) -> Double {
        return weight / (height * height)
    }
}

#Preview {
    ContentView()
}

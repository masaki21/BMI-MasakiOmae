//
//  ContentView.swift
//  BMI
//
//  Created by MAC on 2/11/25.
//

import SwiftUI

// 読み込み中/エラー時の表示
struct LoadPhaseView: View {
    let title: String
    var body: some View {
        VStack(spacing: 8) {
            ProgressView()
            Text(title).font(.footnote)
        }
        .frame(maxWidth: .infinity, minHeight: 160)
    }
}

// 画像を非同期で表示する行
struct AsyncImageRow: View {
    let urlString: String

    var body: some View {
        AsyncImage(
            url: URL(string: urlString),
            transaction: .init(animation: .easeIn)
        ) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFit()                // 画像の縦横比を維持してフィット
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.vertical, 8)

            } else if phase.error != nil {
                LoadPhaseView(title: "画像取得エラー")

            } else {
                LoadPhaseView(title: "画像を取得中です…")
            }
        }
    }
}

struct ContentView: View {
    
    @State private var enteredheight: Double = 0.0 // TextFieldに入力した身長の変数
    @State private var enteredweight: Double = 0.0 // TextFieldに入力した体重の変数
    @State private var originalUnit = "meter" // 元(換算する前)の単位を格納する変数
    
    @FocusState private var isFocused: Bool // フォーカスされているかの変数
    
    let lengthUnits = ["meter", "centimeter"] // 長さの単位一覧
    
    private var convertedNumber: Double = 0 // 換算後の数値。
    
    var body: some View {
        NavigationStack {
            
            ZStack { //Zstackで囲って背景に色をつける
                Color.cyan.opacity(0.2).ignoresSafeArea() //opacityで透明度を追加
                
                
                Form {
                    Section("入力"){
                        HStack{
                            TextField("Original", value: $enteredheight, format: .number)
                                .keyboardType(.decimalPad)//.decimalPadで小数を入力できる
                                .padding()
                                .focused($isFocused)
                                .toolbar {
                                    ToolbarItem(placement: .keyboard) {
                                        HStack{
                                            Spacer()
                                            Button {
                                                isFocused = false
                                            } label: {
                                                Text("Done")
                                            }
                                        }
                                    }
                                }
                            
                            Picker("", selection: $originalUnit) {
                                ForEach(lengthUnits, id: \.self) { unit in
                                    Text(unit)
                                }
                            }
                        }
                        HStack{
                            TextField("Original", value: $enteredweight, format: .number)
                                .keyboardType(.decimalPad)
                                .padding()
                                .focused($isFocused)
                            
                            Text("kg")
                        }
                    }
                    Section("結果"){
                        HStack{
                            Text(bmiCaluculation(weight: enteredweight,
                                                 height: lengthConversion(
                                                    oldUnit: originalUnit,
                                                    newUnit: "meter",
                                                    value: enteredheight)), format: .number.precision(.fractionLength(2)))// 小数第2位まで表示
                        }
                        
                    }
                    
                    Section("あなたの肥満度チェック"){
                        HStack{
                            Text(bmiCategory(bmiValue: bmiCaluculation(weight: enteredweight,
                                                                       height: lengthConversion(
                                                                        oldUnit: originalUnit,
                                                                        newUnit: "meter",
                                                                        value: enteredheight))))
                            
                            let bmi = bmiCaluculation(
                                weight: enteredweight,
                                height: lengthConversion(
                                    oldUnit: originalUnit,
                                    newUnit: "meter",
                                    value: enteredheight))
                            
                            if let url = bmiImageURL(for: bmi) {
                                AsyncImageRow(urlString: url)
                                    .frame(height: 220)
                            } else {
                                Text("")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    }
                    .navigationTitle("BMI計算機")  // 画面上部にタイトルを付ける
                    .navigationBarTitleDisplayMode(.inline)
                    //navigationBarの背景色を変更
                    .toolbarBackground(Color.cyan.opacity(0.5), for: .navigationBar)
                    .toolbarBackground(.visible, for:
                            .navigationBar)//navigationBarが常に見える状態に固定する指定
                }
                .scrollContentBackground(.hidden) // ← Form の標準背景を消す
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
    
    func bmiCategory(bmiValue: Double) -> String {
        //guard bmiValue.isFiniteで普通の数（有限の値か？）をチェック
        guard bmiValue.isFinite, bmiValue > 0 else { return "" }
        
        switch bmiValue {
        case ..<18.5:
            return "痩せすぎ"
        case 18.5..<24.9:
            return "標準"
        case 25...:
            return "肥満"
        default:
            return ""
        }
    }
    
// BMIに応じて表示する画像URLを返す
    func bmiImageURL(for bmiValue: Double) -> String? {
        guard bmiValue.isFinite, bmiValue > 0 else { return nil }
        switch bmiValue {
        case ..<18.5:
            return "https://thumb.ac-illust.com/bf/bf056e85835c5493c6901b3b8f99adb0_t.jpeg"
        case 18.5..<24.9:
            return "https://thumb.ac-illust.com/97/97dda980ca6d9de6617a50011c71a8d5_t.jpeg"
        case 25...:
            return "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhfPnCD8SXUkZ8qcDXlAl23-VM8A9fIhh41-0s5ngthk1IOydii397IpcoybLGG9xdDdFY0Cx8Bic-Fa2OTk4bEv_CoXLA58oyQaVIlt88yg3T1kjCLEjr4SMFd8TwtILVKUa6YmwcHRl0W/s800/diet_before_man.png"
        default:
            return nil
        }
}


#Preview {
    ContentView()
}

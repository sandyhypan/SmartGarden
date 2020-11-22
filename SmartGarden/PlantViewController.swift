//
//  PlantViewController.swift
//  SmartGarden
//
//  Created by England Kwok on 3/11/20.
//  Copyright © 2020 Sandy Pan. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Cosmos
import Charts
import FirebaseAuth

class PlantViewController: UIViewController, ChartViewDelegate {
    @IBOutlet weak var moistureChart: LineChartView!

    @IBOutlet weak var temperatureChart: LineChartView!
    @IBOutlet weak var lightChart: LineChartView!
    @IBOutlet weak var autoWateringSwitch: UISwitch!
    @IBOutlet weak var waterTankVolume: CosmosView!
    @IBOutlet weak var plantNameLabel: UILabel!
    @IBOutlet weak var plantImageView: UIImageView!
    var ref: DatabaseReference?
    var plant: Plant?
    var userID: String = ""
    var counter: Int = 0
    var luxRecords = [Double]()
    var moistureRecords = [Double]()
    var soilTempRecords = [Double]()
    var dateRecords = [String]()
    weak var axisFormatDelegate: IAxisValueFormatter?
    var x:[String] = []
    var totalRecords: Int = 0
    @IBOutlet weak var waterSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefaults = UserDefaults.standard
        userID = userDefaults.string(forKey: "uid")!
        plantNameLabel.text = plant?.plantName
        plantImageView.image = UIImage(data: (plant?.plantPhoto)!)
        
        
        //Line chart delegates
        axisFormatDelegate = self
        moistureChart.delegate = self
        lightChart.delegate = self
        temperatureChart.delegate = self
        //Cosmos
        waterTankVolume.settings.updateOnTouch = false
        //set the reference of firebase
        ref = Database.database().reference()
        retrieveAllRecords()
        
        let ref = self.ref?.child(userID).child((plant?.macAddress)!).child("auto_water")
        ref?.observeSingleEvent(of: .value, with: { (snapshot) in
            let isOn = snapshot.value as! Bool
            
            self.waterSwitch.setOn(isOn, animated: false)
        })
        
        
        
  
    }
    
    @IBAction func switchChange(_ sender: UISwitch) {
        var flag = "off"
        if sender.isOn{
            flag = "start/\((Auth.auth().currentUser?.uid)!)"
        } else {
            flag = "stop"
        }
        
        let UrlString = "http://\(plant!.ipAddress!):5000/\(flag)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let switchURL = URL(string: UrlString!)!
        let dataTask = URLSession.shared.dataTask(with: switchURL) {(data, response, error) in
            
            if let error = error{
                print(error.localizedDescription)
                return
            }
            
        }
        dataTask.resume()
    }
    
    
        
    //MARK: - Populate chart views
    //Reference: https://stackoverflow.com/questions/39049188/how-to-add-strings-on-x-axis-in-ios-charts
    
    func setLineChart(dataEntryX forX:[String], dataEntryY forY: [Double], lineChart: LineChartView){
            var entries:[ChartDataEntry] = []
            var axisMin: Double
            var axisMax: Double
            axisMin = Double(round(10 * forY.min()!)/10)  - 0.1
            axisMax = Double(round(10 * forY.max()!)/10)  + 0.1
            for i in 0..<forX.count{
                let dataEntry = ChartDataEntry(x: Double(i), y: Double(forY[i]), data: dateRecords as AnyObject?)
                entries.append(dataEntry)
            }
            
            let chartDataSet = LineChartDataSet(entries: entries, label: "Moisture Level")
            chartDataSet.mode = .cubicBezier
            chartDataSet.lineWidth = 2
            chartDataSet.circleRadius = 0.5
            let green = UIColor(red:133/255, green:224/255,blue:133/255,alpha:1)
            let lightGreen = UIColor(red:133/255, green:224/255,blue:133/255,alpha:0.5)
            chartDataSet.setColor(green, alpha: 1)
            chartDataSet.circleColors = [green]
            let gradientColors = [green.cgColor, lightGreen.cgColor] as CFArray
            let colorLocation: [CGFloat] = [0.0, 1.0]
            let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(),colors: gradientColors, locations:colorLocation)
            chartDataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: 90)
            chartDataSet.drawFilledEnabled = true
            
            let chartData = LineChartData(dataSet: chartDataSet)
            lineChart.data = chartData
            lineChart.drawBordersEnabled = true
            lineChart.borderColor = UIColor(red:220/255, green:220/255,blue:220/255,alpha:1)
            lineChart.xAxis.drawGridLinesEnabled = false
            lineChart.xAxis.valueFormatter = axisFormatDelegate
            lineChart.extraTopOffset = 3
            lineChart.extraBottomOffset = 10
            lineChart.xAxis.avoidFirstLastClippingEnabled = true
    //        lineChart.xAxis.labelRotationAngle = -45.0
            lineChart.xAxis.wordWrapEnabled = true
            lineChart.xAxis.setLabelCount(totalRecords, force: true)
            lineChart.xAxis.forceLabelsEnabled = true
            lineChart.backgroundColor = UIColor(red:236/255, green:236/255,blue:236/255,alpha:1)
            lineChart.xAxis.drawAxisLineEnabled = false
            lineChart.xAxis.drawLimitLinesBehindDataEnabled = false
            lineChart.xAxis.gridColor = UIColor(red:220/255, green:220/255,blue:220/255,alpha:1)
            lineChart.xAxis.gridLineWidth = 0.5
            lineChart.xAxis.drawGridLinesEnabled = true
    //        lineChart.xAxis.drawLabelsEnabled = false
            lineChart.leftAxis.removeAllLimitLines()
            lineChart.leftAxis.drawZeroLineEnabled = false
            lineChart.leftAxis.zeroLineWidth = 0
            lineChart.leftAxis.drawTopYLabelEntryEnabled = false
            lineChart.leftAxis.drawAxisLineEnabled = false
            lineChart.leftAxis.drawGridLinesEnabled = false
    //        lineChart.leftAxis.drawLabelsEnabled = false
            lineChart.leftAxis.drawLimitLinesBehindDataEnabled = false
            lineChart.leftAxis.axisMinimum = axisMin
            lineChart.leftAxis.axisMaximum = axisMax
            lineChart.rightAxis.removeAllLimitLines()
            lineChart.rightAxis.drawZeroLineEnabled = false
            lineChart.leftAxis.zeroLineWidth = 0
            lineChart.rightAxis.drawTopYLabelEntryEnabled = false
            lineChart.rightAxis.drawAxisLineEnabled = false
            lineChart.rightAxis.drawGridLinesEnabled = false
            lineChart.rightAxis.drawLabelsEnabled = false
            lineChart.rightAxis.drawLimitLinesBehindDataEnabled = false
            lineChart.legend.enabled = false
            lineChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
            
        }
    
    
    //MARK: - Firebase Data Retrieval
    //Reference: https://stackoverflow.com/questions/59744053/fill-an-array-through-a-nested-firebase-data-loop-swift
    
    func retrieveAllRecords(){
        let userRef = self.ref?.child(userID)
        let deviceRef = userRef?.child((plant?.macAddress)!)
        let dataRef = deviceRef?.child("data")
        //Order the records in ascending order
        dataRef?.queryOrdered(byChild: "Timestamp") .observe(.value, with: { (snapshot) in
            let childRecords = snapshot.children.allObjects as! [DataSnapshot]
            self.totalRecords = childRecords.count
            self.counter = 1
            //Loop through all records from the most recent
            for record in childRecords.reversed(){
                //Read data from a single record
                self.readSingleRecord(node: record.key)
                //Get the most recent 20 records
                if self.counter == 21 {
                    break
                }
            }
        })
        
    }
    
    func readSingleRecord(node: String){
        let userRef = self.ref?.child(userID)
        let deviceRef = userRef?.child((plant?.macAddress)!)
        let dataRef = deviceRef?.child("data")
        let recordRef = dataRef?.child(node)
        recordRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            //Obtain the sensor readings and populate them into arrays
            let lux = snapshot.childSnapshot(forPath: "Lux").value as? Double ?? 0
            self.luxRecords.insert(lux, at: 0)
            let moisture = snapshot.childSnapshot(forPath: "Moisture").value as? Double ?? 0
            self.moistureRecords.insert(moisture, at: 0)
            let temp = snapshot.childSnapshot(forPath: "Temperature").value as? Double ?? 0
            self.soilTempRecords.insert(temp, at: 0)
            
            let timestamp = snapshot.childSnapshot(forPath: "Timestamp").value as? Double ?? 0
            let localDate = self.timestampCorrector(timeStamp: timestamp)
            self.dateRecords.insert(localDate, at: 0)
            
            
            //Get only the most recent water tank level reading record
            if self.counter == 1 {
                let waterLevel = snapshot.childSnapshot(forPath: "Water level").value as? Double ?? 0
                let containerVolume = snapshot.childSnapshot(forPath: "Container Volume").value as? Double ?? 0
                
                //If the water tank sensor data is less than 0
                var waterVol: Double = 0
                if waterLevel <= 0{
                    waterVol = 0
                } else {
                    waterVol = waterLevel
                }
                
                if containerVolume <= 0{
                    self.waterTankVolume.rating = 0
                } else {
                    self.waterTankVolume.rating = waterVol/containerVolume
                }
                
            }
            let charts:[LineChartView] = [self.moistureChart, self.lightChart, self.temperatureChart]
            var y:[Double] = []
            if self.totalRecords < 20{
                if  self.counter == self.totalRecords{
                    for i in charts{
                        if i == self.moistureChart{
                            y = self.moistureRecords
                        } else if i == self.lightChart {
                            y = self.luxRecords
                        } else {
                            y = self.soilTempRecords
                        }
                        self.setLineChart(dataEntryX: self.dateRecords, dataEntryY: y, lineChart: i)
                    }
                }
            } else {
                if self.counter == 20{
                    
                    for i in charts{
                        if i == self.moistureChart{
                            y = self.moistureRecords
                        } else if i == self.lightChart {
                            y = self.luxRecords
                        } else {
                            y = self.soilTempRecords
                        }
                        self.setLineChart(dataEntryX: self.dateRecords, dataEntryY: y, lineChart: i)
                    }
                }
            }
            
            self.counter += 1
        })
    }
    
    func timestampCorrector(timeStamp: Double) -> String{
        let str = String(timeStamp)
        let start = str.startIndex
        let end = str.index(str.endIndex, offsetBy: -5)
        let range = start..<end
        let substring = str[range]
        let correctDate = Double(substring)!
        let date = Date(timeIntervalSince1970: correctDate)
        let formatter = DateFormatter()
//        formatter.timeStyle = DateFormatter.Style.short
//        formatter.dateStyle = DateFormatter.Style.short
        formatter.dateFormat = "dd/MM HH:mm"
        formatter.timeZone = .current
        let localDate = formatter.string(from: date)
        
        return localDate
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "plantSettingSegue"{
            let destination = segue.destination as! PlantSettingViewController
            destination.plant = plant
            
            
        }
    }
    

}

extension PlantViewController: IAxisValueFormatter{
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateRecords[Int(value)]
    }
}

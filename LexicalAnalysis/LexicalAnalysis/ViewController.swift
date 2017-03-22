//
//  ViewController.swift
//  LexicalAnalysis
//
//  Created by 吴子鸿 on 16/9/13.
//  Copyright © 2016年 吴子鸿. All rights reserved.
//

import Cocoa

class ViewController: NSViewController,NSTableViewDataSource,NSTableViewDelegate {
    var DFAMachine:LexicalClass=LexicalClass(s: "")

    @IBOutlet weak var LexicalText: NSTextField!
    
    @IBOutlet weak var JudgeText: NSTextField!
    
    @IBOutlet weak var JudgeButton: NSButton!
    
    @IBOutlet weak var tableview: NSTableView!
    
    @IBOutlet weak var LexicalLabel: NSTextField!
    
    @IBOutlet weak var BeginNodeLabel: NSTextField!
    
    @IBOutlet weak var EndNodeLabel: NSTextField!
    
    var tableviewColumn:[NSTableColumn]=[]
    
    var DFATable:[(String,[(Character,String)])]=[] //tableview 数据  (哪个节点，输入哪个character到哪个节点)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.removeTableColumn(tableview.tableColumns[0])
        JudgeButton.enabled=false
        
        //将三个按钮移动下来
        self.performSelector(#selector(viewshou), withObject: nil, afterDelay: 0.1)      //延时操作
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    override func awakeFromNib() {
        self.view.wantsLayer=true
        if self.view.layer != nil {
            //let color : CGColorRef = CGColorCreateGenericRGB(0.8, 0.9, 0.9, 0.5)    //修改背景色为绿色
            let color : CGColorRef = CGColorCreateGenericRGB(1, 1, 1, 0.3)
            self.view.layer?.backgroundColor=color
            //self.view.window?.backgroundColor=NSColor(CGColor: color)
        }
        
    }
    
    func viewshou()     //将三个按钮移到界面上
    {
        
        self.view.window!.titlebarAppearsTransparent = true
        self.view.window!.titleVisibility = NSWindowTitleVisibility.Hidden
        self.view.window!.styleMask |= NSFullSizeContentViewWindowMask
        
    }

    @IBAction func CalLexical(sender: NSButton) {       //输入算式，生成自动机

        DFAMachine=LexicalClass(s: LexicalText.stringValue)
        DFAMachine.LexicalDeal()
        if (DFAMachine.iswrong)
        {
            let myAlert=NSAlert()
            myAlert.messageText="Wrong!"
            myAlert.informativeText="输入字串有误"
            myAlert.alertStyle=NSAlertStyle.WarningAlertStyle
            myAlert.beginSheetModalForWindow(self.view.window!, completionHandler: { (choice:NSModalResponse) ->
                Void in })
            JudgeButton.enabled=false
            return
        }
        DFAMachine.nilNode()
        DFAMachine.NFAtoDFA()
        DFAMachine.CreateDFATable()
        self.DFATable=DFAMachine.DFATable
        
        for i in tableview.tableColumns
        {
            tableview.removeTableColumn(i)
        }
        tableviewColumn=[]
        
        for node in self.DFATable       //添加不同标识符的列
        {
            let nextNode=node.1
            for nextNodeKey in nextNode
            {
                var isexist=false
                for z in tableviewColumn
                {
                    if z.identifier == String(nextNodeKey.0)
                    {
                        isexist=true
                    }
                }
                if (isexist == false)
                {
                    let newcolumn=NSTableColumn(identifier: String(nextNodeKey.0))
                    tableviewColumn.append(newcolumn)
                }
            }
        }
        tableview.addTableColumn(NSTableColumn(identifier: "Node"))
        for column in tableviewColumn
        {
            tableview.addTableColumn(column)
        }
        
        LexicalLabel.stringValue="当前式: \(LexicalText.stringValue)"
        LexicalText.stringValue=""
        BeginNodeLabel.stringValue="起始节点:"+DFAMachine.beginnode.s[0]
        EndNodeLabel.stringValue="结束节点:"+DFAMachine.FindEndNode()
        
        tableview.reloadData()  //更新tableview
        
        JudgeButton.enabled=true

    }

    @IBAction func JudgeLexical(sender: NSButton) {     //判断字符串是否满足输入的正则式
        if (DFAMachine.TestLexical(JudgeText.stringValue))
        {
            let myAlert=NSAlert()
            myAlert.messageText="Bingo!"
            myAlert.informativeText="字符串满足正则表达式"
            myAlert.alertStyle=NSAlertStyle.InformationalAlertStyle
            myAlert.beginSheetModalForWindow(self.view.window!, completionHandler: { (choice:NSModalResponse) ->
                Void in })
        }
        else
        {
            let myAlert=NSAlert()
            myAlert.messageText="Wrong!"
            myAlert.informativeText="字符串不满足正则表达式"
            myAlert.alertStyle=NSAlertStyle.WarningAlertStyle
            myAlert.beginSheetModalForWindow(self.view.window!, completionHandler: { (choice:NSModalResponse) ->
                Void in })
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let columnIdentifier = tableColumn?.identifier else {
            return nil
        }
        if row == 0
        {
            let cellView = tableView.makeViewWithIdentifier("cell", owner: self) as! NSTableCellView
            cellView.textField?.stringValue = columnIdentifier
            
            return cellView
        }
        else
        {
            if (row-1 > DFATable.count-1)       //行数超出了，不算了，就这样～
            {
                return nil
            }
            let nownode=self.DFATable[row-1]
            if (columnIdentifier == "Node")
            {
                let cellView = tableView.makeViewWithIdentifier("cell", owner: self) as! NSTableCellView
                cellView.textField?.stringValue = nownode.0
                
                return cellView
            }
            else
            {
                let cellView = tableView.makeViewWithIdentifier("cell", owner: self) as! NSTableCellView
                let nodenext=nownode.1
                cellView.textField?.stringValue = ""
                for i in nodenext
                {
                    if String(i.0) == columnIdentifier
                    {
                        cellView.textField?.stringValue = i.1
                    }
                }
                return cellView
            }
            
        }
        
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return DFATable.count+1
    }

}


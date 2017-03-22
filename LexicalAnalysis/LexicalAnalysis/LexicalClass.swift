//
//  LexicalClass.swift
//  LexicalAnalysisCom
//
//  Created by 吴子鸿 on 16/9/13.
//  Copyright © 2016年 吴子鸿. All rights reserved.
//

import Foundation

class Node {
    var isbegin:Bool=false
    var isend:Bool=false
    var isrenil:Bool=false  //在去空节点时候判断这个节点是否被去空过  和    在寻找end节点时标记是否走过这个节点
    var isfinded:Bool=false //在去空节点时候寻找非空节点时是否被访问过(回溯?)
    var s:[String]=[]       //对每个节点进行编号
    var key:Character   //当前字符
    var list:[Node]  //记录下一个连接的是谁
    init(){
        self.key=" "
        self.list=[]
        
        self.isbegin=false
        self.isend=false
    }
    func copynode(node:Node)        //因为不是结构体所以拷贝节点。。。
    {
        self.isbegin=node.isbegin
        self.isend=node.isend
        self.isrenil=node.isrenil
        self.s=node.s
        self.key=node.key
        self.list=node.list
    }
}
class LexicalClass {
    var charstuck:[(Node,Node)]=[]       //字符的"栈"
    var markstuck:[(Character,Int)]=[]        //符号的"栈"
    var regex:String                //要处理的字串
    var iswrong:Bool=false          //初始化时候判断字符串是否有误
    var beginnode=Node()            //图的开始
    var DFAbeginnode=Node()
    
    var EndNodeStr=""
    
    var DFATable:[(String,[(Character,String)])]=[]

    init (s:String)
    {
        self.regex=s
        var isok=false
        while (isok == false)       //处理()*
        {
            isok=true
            for i in 0..<regex.characters.count
            {
                if (regex[regex.startIndex.advancedBy(i)] == "*")
                {
                    if (regex[regex.startIndex.advancedBy(i-1)] == ")" && regex[regex.startIndex.advancedBy(i-2)] == "(")
                    {
                        regex.removeAtIndex(regex.startIndex.advancedBy(i))
                        regex.removeAtIndex(regex.startIndex.advancedBy(i-1))
                        regex.removeAtIndex(regex.startIndex.advancedBy(i-2))
                        isok=false
                        break
                    }
                }
                
            }
        }

        beginnode.isbegin=true
    }
    func LexicalDeal(){     //进行字符串处理
        for i in 0..<regex.characters.count       //遍历每一个字符，进行处理
        {
            if (iswrong)
            {
                return
            }
            let Recentchar=regex[regex.startIndex.advancedBy(i)]
            if (Recentchar == "(")
            {
                DealLeftBracket(i)
            }
            else if (Recentchar == ")")
            {
                DealRightBracket(i)
            }
            else if (Recentchar == "|")
            {
                DealOr(i)
            }
            else if (Recentchar == "*")
            {
                DealAny(i)
                
            }
            else            //是数字／字母／其他符号
            {
                let anode=Node()        //begin
                let bnode=Node()        //end
                anode.key=Recentchar    //记录当前字符
                anode.list.append(bnode)
                self.charstuck.append((anode,bnode))
            }
        }
        //将charstuck中的东西连接起来
        var stra:Node
        var strb:Node
        (stra,strb)=self.charstuck.popLast()!
        strb.isend=true
        while (self.charstuck.count>0)
        {
            var anode:Node
            var bnode:Node
            (anode,bnode)=self.charstuck.popLast()!
            bnode.list.append(stra)
            stra=anode
        }
        
        if (stra.key == " ")
        {
            stra.isbegin=true
            beginnode=stra
        }
        else
        {
            beginnode=Node()
            beginnode.isbegin=true
            beginnode.list.append(stra)
        }
    }
    func DealLeftBracket(i:Int)     //处理左括号
    {
        self.markstuck.append(("(",self.charstuck.count))
    }
    func DealRightBracket(i:Int)        //处理右括号
    {
        var char:Character
        var x:Int=0
        (char,x)=self.markstuck.last!
        if (x != self.charstuck.count+1)
        {
            while (x<self.charstuck.count-1)
            {
                var anode:Node
                var bnode:Node
                (anode,bnode)=self.charstuck.popLast()!
                var lastanode:Node
                var lastbnode:Node
                (lastanode,lastbnode)=self.charstuck.popLast()!
                lastbnode.list.append(anode)
                self.charstuck.append((lastanode,bnode))
            }
        }
        var RecentMark:Character
        let anode:Node=Node()       //新建起始节点
        let bnode:Node=Node()         //新建结束节点
        var stra:Node
        var strb:Node
        (stra,strb)=self.charstuck.popLast()!       //弹出第一个节点并连接
        anode.list.append(stra)
        strb.list.append(bnode)
        repeat
        {
            if (self.markstuck.count == 0)      //输入表达式有误，找不到左括号
            {
                iswrong=true
                break
            }
            (RecentMark,_)=self.markstuck.popLast()!
            if (RecentMark == "|")  //括号中的或运算
            {
                (stra,strb)=self.charstuck.popLast()!       //弹出or的节点并连接
                anode.list.append(stra)
                strb.list.append(bnode)
            }
            else    //遇到了左括号
            {
                break
            }
        }while(1==1)
        self.charstuck.append((anode,bnode))
        
    }
    func DealOr(i:Int)              //处理 or 运算
    {
        if (self.charstuck.count>0)
        {
            var char:Character
            var x:Int=0
            (char,x)=self.markstuck.last!
            if (x != self.charstuck.count+1)
            {
                while (x<self.charstuck.count-1)
                {
                    var anode:Node
                    var bnode:Node
                    (anode,bnode)=self.charstuck.popLast()!
                    var lastanode:Node
                    var lastbnode:Node
                    (lastanode,lastbnode)=self.charstuck.popLast()!
                    lastbnode.list.append(anode)
                    self.charstuck.append((lastanode,bnode))
                }
            }
        }
        self.markstuck.append(("|",self.charstuck.count))
    }
    func DealAny(i:Int)             //处理 ＊ 运算
    {
        let anode:Node=Node()       //新建起始节点
        var stra:Node
        var strb:Node
        (stra,strb)=self.charstuck.popLast()!       //把重复无限次的连到end节点上
        anode.list.append(stra)
        strb.list.append(anode)
        self.charstuck.append((anode,anode))
        
    }
    
    
    
    func nilNode()  //处理空节点
    {
        var tnode=beginnode
        RemoveNilNode(&tnode)        //递归处理
        beginnode.s.append("0")
        var x:Int=1
        marknode(&x, tnode: beginnode)
    }
    
    func RemoveNilNode(inout tnode:Node)      //处理每一个点相连的空节点
    {
        if (tnode.isrenil == false)
        {
            tnode.isrenil=true
            var AvailableP:[Node]=[]
            AvailableP.append(tnode)        //将这个节点添加进去，后面要改变状态
            findAvailable(&AvailableP, tnode: tnode)
            AvailableP.removeAtIndex(0)     //移除tnode本节点
            tnode.list=AvailableP
            for i in 0..<tnode.list.count
            {
                RemoveNilNode(&tnode.list[i])
            }
        }
        
    }
    
    func findAvailable(inout AvailableP:[Node],tnode:Node)      //inout关键字，传递引用地址  递归寻找非空节点
    {
        for i in 0..<tnode.list.count
        {
            if (tnode.list[i].key != " ")
            {
                AvailableP.append(tnode.list[i])
            }
            else
            {
                if (tnode.list[i].isend == true)
                {

                    AvailableP[0].isend=true
                }
                if (tnode.list[i].isfinded == false)        //这个节点在寻找非空节点时候没有进入过递归
                {
                    tnode.list[i].isfinded=true
                    findAvailable(&AvailableP, tnode: tnode.list[i])
                    tnode.list[i].isfinded=false        //恢复状态
                }
            }
        }
    }
    
    func marknode(inout k:Int,tnode:Node)     //对每个节点进行编号，后面处理集合
    {
        for i in 0..<tnode.list.count
        {
            if (tnode.list[i].s.count==0)
            {
                tnode.list[i].s.append(String(k))
                k=k+1
                marknode(&k, tnode: tnode.list[i])
            }
        }
    }
    
    func NFAtoDFA()
    {
        var QueueL:[Node]=[]        //队列l
        var SetD:[Node]=[]          //集合d
        var charSet:[Character]=[]      //当前节点走向下一个节点的字符有哪些
        var pnode:Node          //当前处理的node
        var DFApnode:Node
        var isexist:Bool=false
        DFAbeginnode.copynode(beginnode)
        DFAbeginnode.list=[]
        QueueL.append(beginnode)
        SetD.append(DFAbeginnode)
        DFApnode=DFAbeginnode
        while (QueueL.count>0)
        {
            pnode=QueueL[0]
            QueueL.removeAtIndex(0)
            charSet.removeAll()
            for i in 0..<pnode.list.count   //找相连的字符的集合
            {
                isexist = false
                if charSet.contains(pnode.list[i].key)
                {
                    isexist=true
                }
                
                if isexist == false
                {
                    charSet.append(pnode.list[i].key)
                }
                else
                {
                    isexist=false
                }
            }
            for ch in charSet
            {
                var newnode=Node()
                newnode.key=ch
                for i in 0..<pnode.list.count   //遍历相连节点，对字符相同的线进行合并节点
                {
                    if pnode.list[i].key == ch
                    {
                        if pnode.list[i].isbegin    //属性加入
                        {
                            newnode.isbegin=true
                        }
                        if (pnode.list[i].isend)    //属性加入
                        {
                            newnode.isend=true
                        }
                        for k in pnode.list[i].s    //将要合成同一个节点的编号加入当前的newnode中
                        {
                            if (newnode.s.contains(k) == false)
                            {
                                newnode.s.append(k)
                            }
                        }
                        for k in pnode.list[i].list     //相连节点加入
                        {
                            isexist=false
                            for x in newnode.list
                            {
                                if (x.s == k.s)
                                {
                                    isexist=true
                                }
                            }
                            if isexist==false
                            {
                                newnode.list.append(k)
                            }
                        }
                    }
                }
                newnode.s.sortInPlace()     //将节点合成后的编号排序、统一
                isexist=false
                for Lnode in SetD     //找到当前要加后边的节点
                {
                    if Lnode.s == pnode.s
                    {
                        DFApnode=Lnode
                    }
                }
                for Dnode in SetD
                {
                    if Dnode.s == newnode.s     //扩展出的节点newnode已经在集合中存在了，那么只需要加入list就可以
                    {
                        isexist=true
                        DFApnode.list.append(Dnode)
                    }
                }
                if (isexist == false)       //将不含list的newnode加入集合中，集合中的点用来扩展新节点，将newnode加入队列中
                {
                    let anewnode=Node()
                    anewnode.copynode(newnode)
                    anewnode.list=[]
                    DFApnode.list.append(anewnode)
                    SetD.append(anewnode)
                    QueueL.append(newnode)
                }
                else
                {
                    isexist=false
                }
                newnode=Node()

            }
            
        }
    }
    
    func FindEndNode()->String      //寻找结束节点的标号
    {
        self.FindEndNode(DFAbeginnode)
        return self.EndNodeStr
    }
    
    func FindEndNode(tnode:Node)
    {
        tnode.isrenil=false     //标记是否被遍历过，遍历完成后所有节点的isrenil为false
        if (tnode.isend)
        {
            if (self.EndNodeStr.characters.count>0)
            {
                var Name:String=""
                for s in tnode.s     //下一个的名称
                {
                    Name=Name+s
                }
                self.EndNodeStr=self.EndNodeStr+","+Name
            }
            else
            {
                var Name:String=""
                for s in tnode.s     //下一个的名称
                {
                    Name=Name+s
                }
                self.EndNodeStr=Name
            }
        }
        for i in tnode.list
        {
            if i.isrenil
            {
                FindEndNode(i)
            }
        }
        
    }
    
    func TestLexical(s:String)->Bool        //测试字符串是不是满足正则表达式
    {
        var DFAnode:Node=DFAbeginnode
        var findit:Bool=false
        for ch in s.characters
        {
            findit=false
            for i in 0..<DFAnode.list.count
            {
                if (ch == DFAnode.list[i].key)
                {
                    findit=true
                    print(DFAnode.list[i].s)
                    DFAnode=DFAnode.list[i]
                    break
                }
            }
            if (findit == false)
            {
                return false
            }
        }
        if DFAnode.isend == true
        {
            return true
        }
        else
        {
            return false
        }
    }

    
    
    func CreateDFATable()       //生成dfa表
    {
        CreateDFATable(self.DFAbeginnode)
    }
    
    func CreateDFATable(tnode:Node)
    {
        tnode.isrenil=true      //标记是否被遍历过  遍历完成后所有节点的isrenil为true
        var NodeName=""
        for s in tnode.s        //当前名称
        {
            NodeName=NodeName+s
        }
        var nextlist:[(Character,String)]=[]
        for next in tnode.list
        {
            var nextName:String=""
            for s in next.s     //下一个的名称
            {
                nextName=nextName+s
            }
            nextlist.append((next.key,nextName))
        }
        self.DFATable.append((NodeName,nextlist))
        
        for next in tnode.list
        {
            if next.isrenil == false
            {
                CreateDFATable(next)
            }
        }
        
    }

    
    

}
class Interval : Identifiable {
    var span : Int
    var name: String
    var id: Int {
        span
    }
    
    init(span:Int, name:String) {
        self.span = span
        self.name = name
    }
}

class Intervals {
    var list:[Interval] = []
    init() {
        self.list.append(Interval(span: 0, name: "Perfect unison"))
        self.list.append(Interval(span: 1, name: "Minor Second"))
        self.list.append(Interval(span: 2, name: "Major Second"))
        self.list.append(Interval(span: 3, name: "Minor Third"))
        self.list.append(Interval(span: 4, name: "Major Third"))
        self.list.append(Interval(span: 5, name: "Perfect Fourth"))
        self.list.append(Interval(span: 6, name: "Tritone"))
        self.list.append(Interval(span: 7, name: "Perfect Fifth"))
        self.list.append(Interval(span: 8, name: "Minor Sixth"))
        self.list.append(Interval(span: 9, name: "Major Sixth"))
        self.list.append(Interval(span: 10, name: "Minor Seventh"))
        self.list.append(Interval(span: 11, name: "Major Seventh"))
        self.list.append(Interval(span: 12, name: "Octave"))
    }
    
    func getName(span:Int) -> String? {
        var name:String?
        for interval in list {
            if interval.span == span {
                name = interval.name
                break
            }
        }
        return name
    }
}

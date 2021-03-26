def ordersIDs(date)
    _IDs = Array.new
    IO.foreach("orders.csv"){|line| 
    _date = line[line.index(',')+1...line.index('T')]
    _ID = line[0...line.index(',')]
    if date==_date
        #puts _ID
        #puts date
        _IDs.push(_ID)
    end}
    return _IDs
end

def productsOrderCount(arrayOfIDs)
    pOC = Hash.new
    IO.foreach("order_items.csv"){ |line|
        orderID = line[0...line.index(',')]
        productID = line[line.index(',')+1...line.rindex(',')]
        count = line[line.rindex(',')+1..line.size]
        for _ID in arrayOfIDs
            if _ID==orderID
                if pOC[productID]==nil
                    pOC[productID]=count.to_i
                else
                    pOC[productID]+=count.to_i
                end
            end
        end
    }
    return pOC
    #pOC.each{|k,v| puts "#{k}=#{v}"}
end

def profitProduct(productsOrdersCountHash)
    pP = Hash.new
    IO.foreach("products.csv"){|line|
        _ID = line[0...line.index(',')]
        _NAME = line[line.index(',')+1...line.rindex(',')]
        _PRICE_PER_UNIT = line[line.rindex(',')+1..line.size]
        productsOrdersCountHash.each{|k,v| 
        #puts "#{k}=#{v}"
        if k == _ID
            if pP[_NAME]==nil
                #puts v.class
                pP[_NAME] = v * _PRICE_PER_UNIT.to_i
            else
                pP[_NAME] += v * _PRICE_PER_UNIT.to_i
            end
        end
        }
    }
    return pP
end

def dailyProfit(date)
    max = 0
    maxNameOfProduct = String.new
    profitProduct(productsOrderCount(ordersIDs(date))).each{|k, v| 
        if v>max
            max=v
        end
    }
    profitProduct(productsOrderCount(ordersIDs(date))).each{|k, v| 
    if v==max
        puts "Date: #{date}. Most profitables product of the day is #{k}, profit: #{v}"
    end
    }   
end

def everyDayProfit
    dateBase = "2021-01-"
    for date in 1..31
        dailyProfit("2021-01-" + (date/10).to_s + (date%10).to_s)
    end
end

everyDayProfit
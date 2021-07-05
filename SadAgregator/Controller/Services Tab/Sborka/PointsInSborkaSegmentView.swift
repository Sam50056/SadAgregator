//
//  PointsInSborkaSegmentView.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 04.07.2021.
//

import SwiftUI

struct PointsInSborkaSegmentView: View {
    
    @ObservedObject var pointsInSborkaSegmentViewModel = PointsInSborkaSegmentViewModel()
    
    var body: some View {
        
        VStack{
            
            List{
                
                ForEach(pointsInSborkaSegmentViewModel.items , id: \.id){ item in
                    
                    ZStack{
                        
                        HStack{
                            
                            Text(item.capt)
                            
                            Spacer()
                            
                            Text(item.summ + " руб.")
                                .foregroundColor(Color(.systemGray))
                            
                        }
                        
                        HStack{
                            
                            Spacer()
                            
                            Text(item.count + " шт.")
                                .foregroundColor(Color(.systemGray))
                            
                            Spacer()
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        .onAppear{
            
            guard pointsInSborkaSegmentViewModel.items.isEmpty else {return}
            
            pointsInSborkaSegmentViewModel.update()
            
        }
        
    }
    
}

struct PointsInSborkaSegmentView_Previews: PreviewProvider {
    static var previews: some View {
        PointsInSborkaSegmentView()
    }
}

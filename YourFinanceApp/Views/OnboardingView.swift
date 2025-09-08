import SwiftUI

struct OnboardingView: View {
    @State private var showingAddAssetFlow = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // 应用图标和标题
            VStack(spacing: 20) {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("家庭资产记账")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("全面管理您的家庭资产和负债")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // 功能介绍
            VStack(spacing: 16) {
                FeatureRow(icon: "banknote", title: "流动资金", description: "支付宝、微信、银行存款等")
                FeatureRow(icon: "house.fill", title: "固定资产", description: "房产、汽车、收藏品等")
                FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "投资理财", description: "股票、基金、理财产品等")
                FeatureRow(icon: "person.2.fill", title: "应收款", description: "借出款项、押金等")
                FeatureRow(icon: "creditcard.fill", title: "负债管理", description: "信用卡、房贷、车贷等")
            }
            .padding(.horizontal)
            
            Spacer()
            
            // 开始按钮
            Button(action: {
                showingAddAssetFlow = true
            }) {
                Text("开始添加资产")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 50)
        }
        .sheet(isPresented: $showingAddAssetFlow) {
            AddAssetFlowView()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
}

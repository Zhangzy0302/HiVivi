import SwiftUI

struct VoiceCoinWalletPage: View {
    let onBack: () -> Void

    @ObservedObject private var voiceCoinRechargeCenter = VoiceCoinStoreKitOneCenter.shared

    private let voiceCoinGreen = Color(red: 0.69, green: 1.0, blue: 0.39)
    private let voiceCoinButtonGreen = Color(red: 0.53, green: 1.0, blue: 0.46)
    private let voiceCoinTextDark = Color(red: 0.05, green: 0.05, blue: 0.06)

    private var voiceCoinGridPackages: [VoiceCoinRechargeProduct] {
        Array(VoiceCoinRechargeCatalog.all.prefix(9))
    }

    private var voiceCoinLongPackage: VoiceCoinRechargeProduct {
        VoiceCoinRechargeCatalog.all[9]
    }

    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { _ in
                VoiceRippleMainBackdrop()
            }

            VStack(alignment: .leading, spacing: 0) {
                Button(action: onBack) {
                    Image("HIVV_back_btn")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        .frame(width: 58, height: 58)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 10)
                .padding(.leading, 22)

                VoiceCoinBalanceCard(
                    balance: voiceCoinRechargeCenter.voiceCoinBalance,
                    green: voiceCoinGreen,
                    textDark: voiceCoinTextDark
                )
                .padding(.top, 14)
                .padding(.horizontal, 22)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 21),
                        GridItem(.flexible(), spacing: 21),
                        GridItem(.flexible(), spacing: 0)
                    ],
                    spacing: 23
                ) {
                    ForEach(voiceCoinGridPackages) { coinVistaCashPack in
                        Button {
                            voiceCoinRechargeCenter.voiceCoinPurchase(coinVistaCashPack)
                        } label: {
                            VoiceCoinRechargeCard(
                                pack: coinVistaCashPack,
                                priceText: voiceCoinRechargeCenter.voiceCoinDisplayPrice(for: coinVistaCashPack),
                                buttonGreen: voiceCoinButtonGreen,
                                textDark: voiceCoinTextDark
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.top, 36)
                .padding(.horizontal, 22)

                Button {
                    voiceCoinRechargeCenter.voiceCoinPurchase(voiceCoinLongPackage)
                } label: {
                    VoiceCoinLongRechargeCard(
                        pack: voiceCoinLongPackage,
                        priceText: voiceCoinRechargeCenter.voiceCoinDisplayPrice(for: voiceCoinLongPackage),
                        buttonGreen: voiceCoinButtonGreen,
                        textDark: voiceCoinTextDark
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 24)
                .padding(.horizontal, 22)

            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            voiceCoinRechargeCenter.voiceCoinReloadBalance()
            voiceCoinRechargeCenter.voiceCoinLoadProductsIfNeeded()
        }
    }
}

private struct VoiceCoinBalanceCard: View {
    let balance: Int
    let green: Color
    let textDark: Color

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 11) {
                Image("HIVV_smile_sun")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 86, height: 76)
                    .padding(.leading, 26)

                VStack(alignment: .trailing, spacing: 14) {
                    Text("Account balance:")
                        .font(VoiceWhisperFontKit.bold(18))
                        .foregroundColor(textDark)

                    HStack(spacing: 8) {
                        Spacer()
                        Image("HIVV_coin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 26, height: 26)

                        Text("\(balance)")
                            .font(VoiceWhisperFontKit.bold(21))
                            .foregroundColor(textDark)
                    }
                    
                }

                Spacer()
            }
            .frame(height: 100)
            .background(green)

            HStack {
                Text("Select the recharge amount")
                    .font(VoiceWhisperFontKit.regular(12))
                    .foregroundColor(Color(red: 0.33, green: 0.33, blue: 0.36))
                    .padding(.leading, 18)

                Spacer()
            }
            .frame(height: 40)
            .background(Color.white)
        }
        .frame(height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct VoiceCoinRechargeCard: View {
    let pack: VoiceCoinRechargeProduct
    let priceText: String
    let buttonGreen: Color
    let textDark: Color

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                Spacer()
                Text(String(pack.coinAmount))
                    .tracking(-0.4)
                    .font(VoiceWhisperFontKit.bold(16))
                    .foregroundColor(textDark)
                    .padding(.top, 15)

                Spacer()

                VoiceCoinCoinStack(size: 15)
                    .padding(.top, 5)
                    .padding(.trailing, 4)
            }

            Spacer()

            Text(priceText)
                .font(VoiceWhisperFontKit.regular(13))
                .foregroundColor(textDark)
                .frame(width: 75, height: 22)
                .background(buttonGreen)
                .clipShape(Capsule())
                .padding(.bottom, 16)
        }
        .frame(width: 98, height: 86)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct VoiceCoinLongRechargeCard: View {
    let pack: VoiceCoinRechargeProduct
    let priceText: String
    let buttonGreen: Color
    let textDark: Color

    var body: some View {
        HStack(spacing: 10) {
            VoiceCoinCoinStack(size: 15)
                .padding(.leading, 18)

            Text(String(pack.coinAmount))
                .font(VoiceWhisperFontKit.bold(18))
                .foregroundColor(textDark)

            Spacer()

            Text(priceText)
                .font(VoiceWhisperFontKit.regular(13))
                .foregroundColor(textDark)
                .frame(width: 75, height: 22)
                .background(buttonGreen)
                .clipShape(Capsule())
                .padding(.trailing, 18)
        }
        .frame(height: 70)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct VoiceCoinCoinStack: View {
    let size: CGFloat

    var body: some View {
        ZStack(alignment: .bottomLeading){
            ZStack(alignment: .center) {
                Circle()
                    .fill(Color.black)
                    .frame(width: 27, height: 27)

                Image("HIVV_coin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                
                
            }
            .frame(width: size + 12, height: size + 18)
            Circle()
                .fill(Color.black)
                .frame(width: 5, height: 5)
                .offset(x: 0, y: 0)
        }
        
    }
}

#Preview("Voice Coin - Wallet") {
    let _ = VoiceWhisperFontKit.registerFonts()
    VoiceCoinWalletPage {}
}

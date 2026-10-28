//
//  page1-aliah.swift
//  ch1
//
//  Created by Aliah on 11/05/1448 AH.
//
import SwiftUI

extension Color {
    static let brownText = Color(red: 0.42, green: 0.27, blue: 0.18)
    static let sparkleYellow = Color(red: 0.97, green: 0.80, blue: 0.40)
}

struct page1_aliah: View {

    // خليها false لو النجوم موجودة أصلاً داخل صورة الباكقراوند
    private let showSparkles = true

    // مواقع النجوم كنسبة من حجم الشاشة (x, y)
    private let sparkles: [(x: CGFloat, y: CGFloat, size: CGFloat)] = [
        (0.37, 0.29, 44),
        (0.59, 0.41, 44),
        (0.10, 0.46, 40),
        (0.81, 0.70, 44),
        (0.33, 0.76, 44)
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {

                // النجوم
                if showSparkles {
                    ForEach(sparkles.indices, id: \.self) { i in
                        Image(systemName: "sparkle")
                            .font(.system(size: sparkles[i].size, weight: .ultraLight))
                            .foregroundStyle(Color.sparkleYellow)
                            .position(
                                x: geo.size.width * sparkles[i].x,
                                y: geo.size.height * sparkles[i].y
                            )
                    }
                }

                // النص
                VStack(alignment: .leading, spacing: 28) {
                    Text("Hey, creative soul!")
                        .font(.system(size: 72, weight: .regular))

                    Text("A little space to draw, relax, and just be you.")
                        .font(.system(size: 48, weight: .regular))
                        .lineSpacing(6)
                }
                .foregroundStyle(Color.brownText)
                .frame(maxWidth: geo.size.width * 0.72, alignment: .leading)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.leading, geo.size.width * 0.12)

                // زر Start تحت يمين
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            // اكتبي هنا الانتقال للشاشة التالية
                        } label: {
                            Text("Start")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(Color.brownText)
                                .frame(width: 290, height: 95)
                                .background(Capsule().fill(Color.white.opacity(0.35)))
                                .overlay(Capsule().strokeBorder(Color.white.opacity(0.7), lineWidth: 1))
                                .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
                        }
                    }
                    .padding(.trailing, 60)
                    .padding(.bottom, 60)
                }
            }
        }
        // صورة الباكقراوند
        .background(
            Image("back")
                .resizable()
                .scaledToFill()
                .scaleEffect(1.06)      // يخفي الزوايا المدورة
                .ignoresSafeArea()
        )
    }
}

#Preview {
    page1_aliah()
}

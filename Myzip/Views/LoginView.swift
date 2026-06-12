import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.indigo.opacity(0.9), .purple.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 12) {
                    Image(systemName: "rectangle.stack.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.white)
                    Text("my.zip")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    Text("나만의 링크 큐레이션")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                VStack(spacing: 14) {
                    TextField("이메일", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .padding()
                        .background(.white.opacity(0.2))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .tint(.white)

                    SecureField("비밀번호", text: $password)
                        .textContentType(isSignUp ? .newPassword : .password)
                        .padding()
                        .background(.white.opacity(0.2))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .tint(.white)

                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        Task {
                            if isSignUp {
                                await authViewModel.signUp(email: email, password: password)
                            } else {
                                await authViewModel.signIn(email: email, password: password)
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            if authViewModel.isLoading { ProgressView().tint(.indigo) }
                            Text(isSignUp ? "회원가입" : "로그인")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white)
                        .foregroundColor(.indigo)
                        .cornerRadius(12)
                    }
                    .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)

                    Button {
                        isSignUp.toggle()
                        authViewModel.errorMessage = nil
                    } label: {
                        Text(isSignUp ? "이미 계정이 있으신가요? 로그인" : "계정이 없으신가요? 회원가입")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.85))
                    }
                }
                .padding(.horizontal, 32)

                Spacer()
            }
        }
    }
}

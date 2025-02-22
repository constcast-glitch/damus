//
//  SideMenuView.swift
//  damus
//
//  Created by Ben Weeks on 1/6/23.
//  Ref: https://blog.logrocket.com/create-custom-collapsible-sidebar-swiftui/

import SwiftUI

struct SideMenuView: View {
    let damus_state: DamusState
    @Binding var isSidebarVisible: Bool

    @State var confirm_logout: Bool = false
    @StateObject var user_settings = UserSettingsStore()
    
    @Environment(\.colorScheme) var colorScheme
    
    var sideBarWidth = min(UIScreen.main.bounds.size.width * 0.65, 400.0)
    
    func fillColor() -> Color {
        colorScheme == .light ? Color("DamusWhite") : Color("DamusBlack")
    }
    
    func textColor() -> Color {
        colorScheme == .light ? Color("DamusBlack") : Color("DamusWhite")
    }
    
    var body: some View {
        ZStack {
            GeometryReader { _ in
                EmptyView()
            }
            .background(Color("DamusDarkGrey").opacity(0.6))
            .opacity(isSidebarVisible ? 1 : 0)
            .animation(.easeInOut.delay(0.2), value: isSidebarVisible)
            .onTapGesture {
                isSidebarVisible.toggle()
            }
            content
        }
        .edgesIgnoringSafeArea(.all)

    }
    
    var content: some View {
        HStack(alignment: .top) {
            ZStack(alignment: .top) {
                fillColor()

                VStack(alignment: .leading, spacing: 20) {
                    let profile = damus_state.profiles.lookup(id: damus_state.pubkey)
                    let followers = FollowersModel(damus_state: damus_state, target: damus_state.pubkey)
                    let profile_model = ProfileModel(pubkey: damus_state.pubkey, damus: damus_state)
                    
                    NavigationLink(destination: ProfileView(damus_state: damus_state, profile: profile_model, followers: followers)) {
                        if let picture = damus_state.profiles.lookup(id: damus_state.pubkey)?.picture {
                            ProfilePicView(pubkey: damus_state.pubkey, size: 60, highlight: .none, profiles: damus_state.profiles, picture: picture)
                        } else {
                            Image(systemName: "person.fill")
                        }
                        VStack(alignment: .leading) {
                            if let display_name = profile?.display_name {
                                Text(display_name)
                                    .foregroundColor(textColor())
                                    .font(.title)
                            }
                            if let name = profile?.name {
                                Text("@" + name)
                                    .foregroundColor(Color("DamusMediumGrey"))
                                    .font(.body)
                            }
                        }
                    }
                    
                    Divider()
                        .padding(.trailing,40)
                    
                    /*
                    HStack(alignment: .bottom) {
                        Text("69,420")
                            .foregroundColor(.accentColor)
                            .font(.largeTitle)
                        Text("SATS")
                            .font(.caption)
                            .padding(.bottom,6)
                    }
                    
                    Divider()
                        .padding(.trailing,40)
                     */
                    
                    // THERE IS A LIMIT OF 10 NAVIGATIONLINKS!!! (Consider some in other views)

                    NavigationLink(destination: ProfileView(damus_state: damus_state, profile: profile_model, followers: followers)) {
                        Label(NSLocalizedString("Profile", comment: "Sidebar menu label for Profile view."), systemImage: "person")
                            .font(.title2)
                            .foregroundColor(textColor())
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        isSidebarVisible = false
                    })
                    
                    /*
                    NavigationLink(destination: EmptyView()) {
                        Label(NSLocalizedString("Relays", comment: "Sidebar menu label for Relay servers view"), systemImage: "xserve")
                            .font(.title2)
                            .foregroundColor(textColor())
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        isSidebarVisible.toggle()
                    })
                    */
                    
                    /*
                    NavigationLink(destination: EmptyView()) {
                        Label(NSLocalizedString("Wallet", comment: "Sidebar menu label for Wallet view."), systemImage: "bolt")
                            .font(.title2)
                            .foregroundColor(textColor())
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        isSidebarVisible.toggle()
                    })
                     */
                    
                    NavigationLink(destination: ConfigView(state: damus_state).environmentObject(user_settings)) {
                        Label(NSLocalizedString("Settings", comment: "Sidebar menu label for accessing the app settings"), systemImage: "gear")
                            .font(.title2)
                            .foregroundColor(textColor())
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        isSidebarVisible = false
                    })
                    
                    Spacer()
                    
                    Button(action: {
                        //ConfigView(state: damus_state)
                        if damus_state.keypair.privkey == nil {
                            notify(.logout, ())
                        } else {
                            confirm_logout = true
                        }
                    }, label: {
                        Label(NSLocalizedString("Sign out", comment: "Sidebar menu label to sign out of the account."), systemImage: "pip.exit")
                            .font(.title3)
                            .foregroundColor(textColor())
                    })
                }
                .padding(.top, 60)
                .padding(.bottom, 40)
                .padding(.leading, 40)
            }
            .frame(width: sideBarWidth)
            .offset(x: isSidebarVisible ? 0 : -sideBarWidth)
            .animation(.default, value: isSidebarVisible)
            .onTapGesture {
                isSidebarVisible.toggle()
            }
            .alert("Logout", isPresented: $confirm_logout) {
                Button(NSLocalizedString("Cancel", comment: "Cancel out of logging out the user.")) {
                    confirm_logout = false
                }
                Button(NSLocalizedString("Logout", comment: "Button for logging out the user.")) {
                    notify(.logout, ())
                }
            } message: {
                Text("Make sure your nsec account key is saved before you logout or you will lose access to this account", comment: "Reminder message in alert to get customer to verify that their private security account key is saved saved before logging out.")
            }

            Spacer()
        }
    }
}

struct Previews_SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        let ds = test_damus_state()
        SideMenuView(damus_state: ds, isSidebarVisible: .constant(true))
    }
}

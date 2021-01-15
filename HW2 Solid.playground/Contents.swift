import UIKit

protocol Storable {
    func saveUser(user: User)
}

enum UserStatus {
    case admin
    case regular
    case ban
}

enum RegistrationError: Error {
    case userExist
}

enum AuthorizationError: Error {
    case bannedUser
    case invalidNameOrPassword
    case userNotAuthorize
}

enum BettingError: Error {
    case restrictedAccess
}

class Storage: Storable {
    var users = [String: User]()
    
    func getUserBy(name: String) -> User? {
        guard users[name] != nil else {
            return nil
        }
        return users[name]!
    }
    
    func userIsExist(name: String) -> Bool {
        if users[name] == nil {
            return false
        } else {
            return true
        }
    }
    
    func saveUser(user: User) {
        users[user.name] = user
    }
}

class User {
    var name: String
    var password: String
    var role: UserStatus
    var isAuthorized: Bool = false
    var bets: Array <String> = []
    
    init(name: String, password: String, role: UserStatus) {
        self.name = name
        self.password = password
        self.role = role
    }
    
    func placeBet(bet: String) {
        guard isAuthorized else { return }
        
        print("\(name) betting \(bet)")
        bets.append(bet)
    }
    
    func printBets() {
        for bet in bets {
            print(bet)
        }
    }
    
    func checkUsers(bettingSystem: BettingSystem) {
        guard isAuthorized else { return }
        guard role == .admin else { return }
        
        for (name, user) in bettingSystem.storage.users {
            if user.bets != [] {
                print("\(name)s bets:")
                user.printBets()
            } else {
                print("\(name) hasn't bets yet")
            }
        }
    }
    
    func makeBan(user: User, bettingSystem: BettingSystem) {
        guard isAuthorized else { return }
        guard role == .admin else { return }
        
        user.role = .ban
        user.isAuthorized = false
    }
}


class BettingSystem {
    let storage: Storage
    
    init() {
        self.storage = Storage()
    }
    
    func register(role: UserStatus, name: String, password: String) throws {
        guard !storage.userIsExist(name: name) else { throw RegistrationError.userExist }
        let user = User.init(name: name, password: password, role: role)
        storage.saveUser(user: user)
        try login(name: name, password: password)
    }
    
    func login(name: String, password: String) throws {
        let user = storage.getUserBy(name: name)
        guard user?.password == password else {
            throw AuthorizationError.invalidNameOrPassword
        }
        guard user?.role != .ban else {
            throw AuthorizationError.bannedUser
        }
        user?.isAuthorized = true
    }
    
    func logout(user: User) {
        user.isAuthorized = false
    }
    
    func placeBet(user: User, bet: String) {
        user.placeBet(bet: bet)
    }
    
    func checkUsersBy(user: User) {
        user.checkUsers(bettingSystem: self)
    }
    
    func banUser(admin: User, regular: User) {
        admin.makeBan(user: regular, bettingSystem: self)
    }
}

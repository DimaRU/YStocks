/////
////  StockType.swift
///   Copyright © 2021 Dmitriy Borovikov. All rights reserved.
//

enum StockType: String, Codable {
    case adr = "ADR"
    case bdr = "BDR"
    case cdi = "CDI"
    case closedEndFund = "Closed-End Fund"
    case commonStock = "Common Stock"
    case dutchCERT = "Dutch Cert"
    case empty = ""
    case equityWRT = "Equity WRT"
    case etp = "ETP"
    case fdic = "FDIC"
    case foreignSh = "Foreign Sh."
    case fundOfFunds = "Fund of Funds"
    case gdr = "GDR"
    case ltdPart = "Ltd Part"
    case misc = "Misc."
    case mlp = "MLP"
    case nvdr = "NVDR"
    case nyRegShrs = "NY Reg Shrs"
    case openEndFund = "Open-End Fund"
    case preference = "Preference"
    case prfdWRT = "Prfd WRT"
    case pvtEqtyFund = "Pvt Eqty Fund"
    case receipt = "Receipt"
    case reit = "REIT"
    case royaltyTrst = "Royalty Trst"
    case savingsShare = "Savings Share"
    case sdr = "SDR"
    case stapledSecurity = "Stapled Security"
    case trackingStk = "Tracking Stk"
    case typeRight = "Right"
    case unit = "Unit"
}

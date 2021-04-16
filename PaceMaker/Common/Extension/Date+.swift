//
//  Date+.swift
//  PaceMaker
//
//  Created by gabriel.jeong on 2021/04/16.
//

import Foundation

extension Date {
    public func toUTCString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter.string(from:self)
    }
    
    public func toTimeString(hourFormat:String, minuteFormat:String) -> String {
        let hourFormatter = DateFormatter()
        let minuteFormatter = DateFormatter()
        
        hourFormatter.dateFormat = "HH"
        minuteFormatter.dateFormat = "mm"
        
        return hourFormat.format(parameters: hourFormatter.string(from: self)) + " " + minuteFormat.format(parameters: minuteFormatter.string(from: self))
    }
    
//    December 25, 2021, 02:02 PM
//    MMMM dd, yyyy, hh:mm a
    public enum PaceFormat {
        ///Format: MM/dd
        case MMddSlash
        
        ///Format: yy/MM/dd"
        case yyMMddSlash
        
        ///Format: yyyy/MM/dd
        case yyyyMMddSlash
        
        ///Format: yyyy-MM-dd
        case yyyyMMddDash
        
        ///Format: MM/dd HH:mm
        case MMddSlashHHmmCol
        
        ///Format: yy/MM/dd HH:mm
        case yyMMddSlashHHmmCol
        
        ///Format: yyyy/MM/dd HH:mm
        case yyyyMMddSlashHHmmCol
        
        ///Format: yyyy.MM.dd
        case yyyyMMddDot
        
        ///Format: HH:mm
        case HHMMCol
        
        ///Format: HH시 mm분
        case HHMMUnit
        
        ///Format: a hh:mm
        case AMPM
        
        ///Format: yyyy.MM.dd hh:mm
        case yyyyMMddDothhmmCol
        
        ///Format: MMMM dd, yyyy, hh:mm a
        case paceDate
        
        ///Format: HH
        case HH
        
        ///Format: mm
        case mm
        
        ///Format: yyyy
        case yyyy
        
        ///Format: MMMM
        case MMMM
        
        ///Format: MM
        case MM
        
        ///Format: dd
        case dd
        
        ///Format: Custom
        case custom(String)
        
        public func formatValue() -> String {
            switch self {
            
            case .MMddSlash:                    return "MM/dd"
            
            case .yyyyMMddSlash:                return "yyyy/MM/dd"
            
            case .yyMMddSlash:                  return "yy/MM/dd"
                
            case .yyyyMMddDash:                 return "yyyy-MM-dd"
            
            case .MMddSlashHHmmCol:             return "MM/dd HH:mm"
            
            case .yyMMddSlashHHmmCol:           return "yy/MM/dd HH:mm"
                
            case .yyyyMMddSlashHHmmCol:         return "yyyy/MM/dd HH:mm"
            
            case .yyyyMMddDot:                  return "yyyy.MM.dd"
            
            case .HHMMCol:                      return "HH:mm"
            
            case .HHMMUnit:                     return "HH시 mm분" //Localizing Issue
            
            case .AMPM:                         return "a hh:mm"
            
            case .yyyyMMddDothhmmCol:           return "yyyy.MM.dd HH:mm"
                
            case .paceDate:                     return "MMMM dd, yyyy, hh:mm a"

            case .yyyy:                         return "yyyy"
                
            case .MMMM:                         return "MMMM"
                
            case .MM:                           return "MM"
                
            case .dd:                           return "dd"
            
            case .HH:                           return "HH"

            case .mm:                           return "mm"
                
            case .custom(let format):           return format
            }
        }
    }
    
    public func string(WithFormat format: PaceFormat, locale: Locale = Locale(identifier: "en_US_POSIX")) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat    = format.formatValue()
        dateFormatter.timeZone      = TimeZone.current
        dateFormatter.locale        = locale    //http://rasbow.zc.bz/bbs/board.php?bo_table=ios_developTip&wr_id=4
        dateFormatter.calendar      = Calendar(identifier: Calendar.Identifier.gregorian)
        return dateFormatter.string(from: self)
    }
}

//
//  Comment+Bee.m
//  Bee
//
//  Created by Emiliano Bivachi on 19/04/14.
//  Copyright (c) 2014 Emiliano Bivachi. All rights reserved.
//

#import "Comment+Bee.h"

@implementation Comment (Bee)

+ (Comment *)newCommentWithDictionary:(NSDictionary *)comment {
    Comment *comm = [[Comment alloc]initWithDictionary:comment];
    if (self) {
        NSDictionary *secret_id = comment[@"id"];
        comm.commentID = secret_id[[[secret_id allKeys] firstObject]];
        comm.avatarID = @"";//secret[@"avatar_id"];
        comm.content = comment[@"content"];
        comm.likesCount = 0;//[secret[@"likes_count"] integerValue];
        comm.iAmAuthor = [comment[@"i_am_author"] boolValue];
        comm.friendIsAuthor = [comment[@"author_is_friend"] boolValue];
        NSString *dateString = comment[@"created_at"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        comm.createdAt = [dateFormat dateFromString:dateString];
        comm.state = CommentSuccessDelivered;
    }
    return comm;
}

+ (Comment *)newCommentWithContent:(NSString *)content {
    Comment *comment = [[Comment alloc] initWithContent:content];
    if (comment) {
        comment.commentID = @"";
        comment.avatarID = @"";//secret[@"avatar_id"];
        comment.content = content;
        comment.likesCount = 0;
        comment.iAmAuthor = YES;
        comment.friendIsAuthor = NO;
        comment.state = CommentDelivered;
    }
    return comment;
}

+ (NSString *)monthStringForMonthNumber:(NSInteger)month {
    switch (month) {
        case 1:
            return @"Enero";
            break;
        case 2:
            return @"Febrero";
            break;
        case 3:
            return @"Marzo";
            break;
        case 4:
            return @"Abril";
            break;
        case 5:
            return @"Mayo";
            break;
        case 6:
            return @"Junio";
            break;
        case 7:
            return @"Julio";
            break;
        case 8:
            return @"Agosto";
            break;
        case 9:
            return @"Septiembre";
            break;
        case 10:
            return @"Octubre";
            break;
        case 11:
            return @"Noviembre";
            break;
        case 12:
            return @"Diciembre";
            break;
        default:
            return @"";
            break;
    }
}

+ (NSString *)weekdayForWeekdayNumber:(NSInteger)weekday {
    switch (weekday) {
        case 1:
            return @"Domingo";
            break;
        case 2:
            return @"Lunes";
            break;
        case 3:
            return @"Martes";
            break;
        case 4:
            return @"Miercoles";
            break;
        case 5:
            return @"Jueves";
            break;
        case 6:
            return @"Viernes";
            break;
        case 7:
            return @"Sabado";
            break;
        default:
            return @"";
            break;
    }
}

- (NSString *)dateString {
    NSTimeInterval interval = [self.createdAt timeIntervalSinceNow];
    if (interval < 0) {
        interval = -interval;
        if (interval < 60.0) {
            return [NSString stringWithFormat:@"Hace %.0f segundos",interval];
        } else if (interval < 60.0*60.0) {
            NSInteger minutos = floorf(interval/60.0);
            return [NSString stringWithFormat:@"Hace %i minutos",minutos];
        } else if (interval < 60.0*60.0*24.0) {
            NSInteger horas = floorf(interval/(60.0*60.0));
            return [NSString stringWithFormat:@"Hace %i horas",horas];
        } else if (interval < 60.0*60.0*24.0*2) {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:self.createdAt];
            return [NSString stringWithFormat:@"Ayer a la(s) %i:%2.i",components.hour,components.minute];
        } else if (interval < 60.0*60.0*24.0*7) {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit |NSWeekdayCalendarUnit) fromDate:self.createdAt];
            NSString *weekday = [Comment weekdayForWeekdayNumber:components.weekday];
            return [NSString stringWithFormat:@"El %@ a la(s) %i:%2.i",weekday,components.hour,components.minute];
        } else if (interval < 60.0*60.0*24.0*365.0) {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit |NSDayCalendarUnit | NSMonthCalendarUnit) fromDate:self.createdAt];
            NSString *month = [Comment monthStringForMonthNumber:components.month];
            return [NSString stringWithFormat:@"El %i de %@ a la(s) %i:%2.i",components.day,month,components.hour,components.minute];
        } else {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit |NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:self.createdAt];
            NSString *month = [Comment monthStringForMonthNumber:components.month];
            return [NSString stringWithFormat:@"El %i de %@ de %i a la(s) %i:%2.i",components.day,month,components.year,components.hour,components.minute];
        }
    } else {
        return @"";
    }
}

@end

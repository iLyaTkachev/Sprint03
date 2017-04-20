//
//  HTTPCommunication.m
//  Sprint03
//
//  Created by iLya Tkachev on 4/16/17.
//  Copyright © 2017 iLya Tkachev. All rights reserved.
//

#import "HTTPCommunication.h"

@implementation HTTPCommunication

- (void)retrieveURL:(NSURL *)url myBlock:(void(^)(NSArray *))block
{
    self.myBlock = block;
    
    // создаем запрос, используя данный url
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    // создаем сессию, используя дефолтную конфигурацию и устанавливая наш экземпляр класса как делегат
    NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:conf delegate:self delegateQueue:nil];
    
    // подготавливаем загрузку
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request];
    
    // устанавливаем HTTP соединение
    [task resume];
}
//получит данные из ответа в THSHTTPCommunication.m. NSURLSession вызовет этот метод как только данные станут доступны и загрузка закончится.
- (void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    // получаем загруженные данные из локального хранилища
    NSData *data = [NSData dataWithContentsOfURL:location];
    NSError *error = nil;
    NSArray *dataArray = [NSJSONSerialization JSONObjectWithData: data options:NSJSONReadingMutableContainers error:&error];//parse in other thread

    if (!error)
    {
        // гарантируем, что вызов successBlock происходит в главном потоке
        dispatch_async(dispatch_get_main_queue(), ^{
            // вызываем сохраненный ранее блок как колбэк
            self.myBlock(dataArray);
        });
    }
}

@end

# YTDB
这是一个灵感来源于ThinkPHP的数据库管理类
当然 作者是个菜鸡 对性能优化不是很懂所以上传上来请大家一起完善。
使用方法如下

  #插入数据
  userModel *model = [userModel new];
    
  model.user_value = @"测试一条数据";
    
  [model yt_openDatabases:^(YTDBDriveMaker *Drive) {
    Drive.M(@"t_user").add();
  }];
    
  #查询数据
  NSArray *MessageList = [MessageModel yt_getDataBasesDataWithToArray:^(YTDBDriveMaker *maker) {
  
    NSMutableDictionary *where = [NSMutableDictionary new];
    
    [where setValue:session forKey:@"message_sessionId"];
     
    NSString *str = [NSString stringWithFormat:@"%ld,%d",(self.CurrentPage - 1) * PageSize,PageSize];
    
    NSArray *messageArray = maker.M(@"t_message").join(@"join t_user on t_user.user_info_Id = t_message.message_sessionId").where(where).limit(str).order(@"message_timestamp desc").select(nil);
    
     maker.modelData =  [[messageArray reverseObjectEnumerator] allObjects];
     
  }];

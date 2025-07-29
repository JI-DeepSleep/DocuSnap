# 缓存与持久化模块

缓存与持久化模块是 DocuSnap-Backend 系统的数据管理组件，负责管理任务状态和处理结果的存储、检索和清理。该模块使用 SQLite 数据库实现轻量级的数据持久化，提高系统性能并保障数据可靠性。

## 模块职责

缓存与持久化模块的主要职责包括：

1. **数据库管理**：创建和维护 SQLite 数据库连接和表结构
2. **任务状态存储**：记录和更新任务的处理状态
3. **结果缓存**：存储任务处理结果，避免重复计算
4. **数据检索**：提供任务状态和结果的查询接口
5. **缓存清理**：定期清理过期的缓存数据，优化存储空间

## 核心组件

### 1. 数据库连接管理器

数据库连接管理器负责创建和管理与 SQLite 数据库的连接，确保数据库操作的可靠性和效率。

**代码示例**：

```python
def get_db_connection():
    """获取数据库连接"""
    try:
        conn = sqlite3.connect(DATABASE_PATH)
        conn.row_factory = sqlite3.Row  # 使结果可通过列名访问
        return conn
    except Exception as e:
        raise Exception(f"数据库连接失败: {str(e)}")

def init_db():
    """初始化数据库，创建必要的表"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # 创建任务表
        cursor.execute('''
        CREATE TABLE IF NOT EXISTS tasks (
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            status TEXT NOT NULL,
            result TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER
        )
        ''')
        
        conn.commit()
        conn.close()
    except Exception as e:
        raise Exception(f"数据库初始化失败: {str(e)}")
```

### 2. 任务数据存储器

任务数据存储器负责将任务状态和结果存储到数据库，并在需要时更新这些信息。

**代码示例**：

```python
def create_task_record(task_id, task_type):
    """创建新的任务记录"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        current_time = int(time.time())
        
        cursor.execute(
            "INSERT INTO tasks (id, type, status, created_at) VALUES (?, ?, ?, ?)",
            (task_id, task_type, 'pending', current_time)
        )
        
        conn.commit()
        conn.close()
    except Exception as e:
        raise Exception(f"创建任务记录失败: {str(e)}")

def update_task_result(task_id, status, result=None):
    """更新任务状态和结果"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        current_time = int(time.time())
        
        if result:
            # 如果提供了结果，将其转换为 JSON 字符串存储
            result_json = json.dumps(result, ensure_ascii=False)
            
            cursor.execute(
                "UPDATE tasks SET status = ?, result = ?, updated_at = ? WHERE id = ?",
                (status, result_json, current_time, task_id)
            )
        else:
            cursor.execute(
                "UPDATE tasks SET status = ?, updated_at = ? WHERE id = ?",
                (status, current_time, task_id)
            )
        
        conn.commit()
        conn.close()
    except Exception as e:
        raise Exception(f"更新任务结果失败: {str(e)}")
```

### 3. 缓存查询器

缓存查询器负责从数据库中检索任务状态和结果，支持系统的缓存机制。

**代码示例**：

```python
def get_task_status(task_id):
    """获取任务状态"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute(
            "SELECT status, created_at, updated_at FROM tasks WHERE id = ?",
            (task_id,)
        )
        
        task = cursor.fetchone()
        conn.close()
        
        if task:
            return {
                'status': task['status'],
                'created_at': task['created_at'],
                'updated_at': task['updated_at']
            }
        else:
            return None
    except Exception as e:
        raise Exception(f"获取任务状态失败: {str(e)}")

def get_task_result(task_id):
    """获取任务结果"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute(
            "SELECT status, result, created_at, updated_at FROM tasks WHERE id = ?",
            (task_id,)
        )
        
        task = cursor.fetchone()
        conn.close()
        
        if task and task['result']:
            return {
                'status': task['status'],
                'result': json.loads(task['result']),
                'created_at': task['created_at'],
                'updated_at': task['updated_at']
            }
        elif task:
            return {
                'status': task['status'],
                'result': None,
                'created_at': task['created_at'],
                'updated_at': task['updated_at']
            }
        else:
            return None
    except Exception as e:
        raise Exception(f"获取任务结果失败: {str(e)}")
```

### 4. 数据清理器

数据清理器负责定期清理过期的缓存数据，优化数据库存储空间和查询性能。

**代码示例**：

```python
def cleanup_expired_tasks(max_age_days=7):
    """清理过期的任务记录"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # 计算过期时间戳（当前时间减去最大保留天数）
        expiration_timestamp = int(time.time()) - (max_age_days * 24 * 60 * 60)
        
        # 删除过期的任务记录
        cursor.execute(
            "DELETE FROM tasks WHERE created_at < ?",
            (expiration_timestamp,)
        )
        
        deleted_count = cursor.rowcount
        conn.commit()
        conn.close()
        
        return deleted_count
    except Exception as e:
        raise Exception(f"清理过期任务失败: {str(e)}")
```

## 数据库设计

缓存与持久化模块使用 SQLite 数据库存储任务状态和结果，数据库设计如下：

### 任务表 (tasks)

| 列名 | 类型 | 描述 |
|------|------|------|
| id | TEXT | 主键，任务唯一标识符 |
| type | TEXT | 任务类型（document, form, form_filling） |
| status | TEXT | 任务状态（pending, processing, completed, error） |
| result | TEXT | 任务结果，JSON 格式 |
| created_at | INTEGER | 创建时间戳 |
| updated_at | INTEGER | 更新时间戳 |

这种设计支持系统的核心缓存需求，同时保持数据库结构的简洁性。

## 缓存策略

缓存与持久化模块实现了以下缓存策略：

1. **结果缓存**：
   - 存储任务处理结果，避免重复计算
   - 相同的输入参数可以直接返回缓存结果
   - 提高系统响应速度和资源利用率

2. **状态跟踪**：
   - 记录任务的处理状态（待处理、处理中、已完成、错误）
   - 支持客户端查询任务进度
   - 实现异步处理模式

3. **时间基缓存管理**：
   - 记录任务的创建和更新时间
   - 定期清理过期缓存数据
   - 优化存储空间和查询性能

4. **错误恢复**：
   - 记录任务处理错误信息
   - 支持错误分析和调试
   - 可能的情况下支持任务重试

## 工作流程

缓存与持久化模块的工作流程如下：

### 数据存储流程

1. **任务创建**：
   - 系统生成唯一的任务 ID
   - 创建任务记录，状态设为"待处理"
   - 记录创建时间戳

2. **状态更新**：
   - 任务开始处理时，状态更新为"处理中"
   - 记录更新时间戳

3. **结果存储**：
   - 任务完成后，状态更新为"已完成"或"错误"
   - 存储处理结果或错误信息
   - 更新更新时间戳

### 数据检索流程

1. **状态查询**：
   - 客户端提供任务 ID
   - 系统查询任务状态
   - 返回状态信息和时间戳

2. **结果查询**：
   - 客户端提供任务 ID
   - 系统查询任务结果
   - 如果任务已完成，返回处理结果
   - 如果任务未完成，返回当前状态

### 缓存清理流程

1. **定期执行**：
   - 系统定期（如每天）执行缓存清理
   - 也可以在服务器负载较低时手动触发

2. **过期判断**：
   - 根据任务创建时间判断是否过期
   - 默认保留期为 7 天

3. **数据删除**：
   - 删除过期的任务记录
   - 释放数据库存储空间

## 事务管理

缓存与持久化模块实现了基本的事务管理，确保数据操作的原子性：

1. **连接管理**：
   - 每个数据库操作获取新的连接
   - 操作完成后关闭连接，释放资源

2. **事务提交**：
   - 数据修改操作后显式提交事务
   - 确保数据写入磁盘

3. **错误处理**：
   - 捕获并处理数据库操作异常
   - 提供详细的错误信息，便于调试

## 模块接口

缓存与持久化模块提供以下主要接口：

1. **对外接口**：
   - `get_task_status`：获取任务状态
   - `get_task_result`：获取任务结果

2. **对内接口**：
   - `get_db_connection`：获取数据库连接
   - `init_db`：初始化数据库
   - `create_task_record`：创建任务记录
   - `update_task_result`：更新任务状态和结果
   - `cleanup_expired_tasks`：清理过期任务

## 性能考量

缓存与持久化模块的性能优化措施包括：

1. **轻量级数据库**：
   - 使用 SQLite 作为轻量级数据库
   - 无需独立的数据库服务器
   - 适合中小规模的缓存需求

2. **索引优化**：
   - 对 `id` 字段建立主键索引
   - 提高任务查询性能

3. **连接管理**：
   - 每个操作使用独立的连接
   - 避免长时间占用连接资源
   - 适合并发访问场景

4. **定期清理**：
   - 清理过期数据，避免数据库膨胀
   - 维持查询性能

## 扩展性

缓存与持久化模块的扩展性体现在：

1. **支持多种存储后端**：
   - 设计支持未来替换为其他数据库系统
   - 可以根据需求升级为更强大的数据库

2. **可扩展的数据模型**：
   - 可以添加新的表和字段，支持更复杂的数据需求
   - 保持向后兼容性

3. **缓存策略优化**：
   - 可以实现更复杂的缓存策略，如基于使用频率的缓存
   - 可以添加缓存预热和缓存失效机制

通过这些设计和实现，缓存与持久化模块为 DocuSnap-Backend 系统提供了高效、可靠的数据存储和检索服务，支持系统的核心功能和性能需求。
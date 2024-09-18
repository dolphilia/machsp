#include "Base.h"
#include "FileSystem.h"
#include "Properties.h"
#include "Stream.h"
#include "Platform.h"

#include <sys/types.h>
#include <sys/stat.h>

#ifdef WIN32
    #include <windows.h>
    #include <tchar.h>
    #include <stdio.h>
    #include <direct.h>
    #define gp_stat _stat
    #define gp_stat_struct struct stat
#else
    #define __EXT_POSIX2
    #include <libgen.h>
    #include <dirent.h>
    #define gp_stat stat
    #define gp_stat_struct struct stat
#endif

#ifdef HSPDISH
//	HSP3 DPM2に対応
#include "../../../hsp3/dpmread.h"
#include "../../../hsp3/filepack.h"
#endif

namespace gameplay
{


/** @script{ignore} */
static std::string __resourcePath("./");
static std::string __assetPath("");
static std::map<std::string, std::string> __aliases;

/**
 * Gets the fully resolved path.
 * If the path is relative then it will be prefixed with the resource path.
 * Aliases will be converted to a relative path.
 * 
 * @param path The path to resolve.
 * @param fullPath The full resolved path. (out param)
 */
static void getFullPath(const char* path, std::string& fullPath)
{
#ifdef HSPDISH
    fullPath.assign(path);
#else
    if (FileSystem::isAbsolutePath(path))
    {
        fullPath.assign(path);
    }
    else
    {
        fullPath.assign(__resourcePath);
        fullPath += FileSystem::resolvePath(path);
    }
#endif
}

/**
 * 
 * @script{ignore}
 */
class FileStream : public Stream
{
public:
    friend class FileSystem;
    
    ~FileStream();
    virtual bool canRead();
    virtual bool canWrite();
    virtual bool canSeek();
    virtual void close();
    virtual size_t read(void* ptr, size_t size, size_t count);
    virtual char* readLine(char* str, int num);
    virtual size_t write(const void* ptr, size_t size, size_t count);
    virtual bool eof();
    virtual size_t length();
    virtual long int position();
    virtual bool seek(long int offset, int origin);
    virtual bool rewind();

    static FileStream* create(const char* filePath, const char* mode);

private:
    FileStream(DpmFile* dpm);

private:
    DpmFile* _file;
    bool _canRead;
    bool _canWrite;
};

/////////////////////////////

FileSystem::FileSystem()
{
}

FileSystem::~FileSystem()
{
}

void FileSystem::setResourcePath(const char* path)
{
    __resourcePath = path == NULL ? "" : path;
}

const char* FileSystem::getResourcePath()
{
    return __resourcePath.c_str();
}

void FileSystem::loadResourceAliases(const char* aliasFilePath)
{
    Properties* properties = Properties::create(aliasFilePath);
    if (properties)
    {
        Properties* aliases;
        while ((aliases = properties->getNextNamespace()) != NULL)
        {
            loadResourceAliases(aliases);
        }
    }
    SAFE_DELETE(properties);
}

void FileSystem::loadResourceAliases(Properties* properties)
{
    assert(properties);

    const char* name;
    while ((name = properties->getNextProperty()) != NULL)
    {
        __aliases[name] = properties->getString();
    }
}

std::string FileSystem::displayFileDialog(size_t dialogMode, const char* title, const char* filterDescription, const char* filterExtensions, const char* initialDirectory)
{
    return Platform::displayFileDialog(dialogMode, title, filterDescription, filterExtensions, initialDirectory);
}

const char* FileSystem::resolvePath(const char* path)
{
    GP_ASSERT(path);

    size_t len = strlen(path);
    if (len > 1 && path[0] == '@')
    {
        std::string alias(path + 1);
        std::map<std::string, std::string>::const_iterator itr = __aliases.find(alias);
        if (itr == __aliases.end())
            return path; // no matching alias found
        return itr->second.c_str();
    }

    return path;
}

bool FileSystem::listFiles(const char* dirPath, std::vector<std::string>& files)
{
#ifdef WIN32
    std::string path(FileSystem::getResourcePath());
    if (dirPath && strlen(dirPath) > 0)
    {
        path.append(dirPath);
    }
    path.append("/*");
    // Convert char to wchar
    std::basic_string<TCHAR> wPath;
    wPath.assign(path.begin(), path.end());

    WIN32_FIND_DATA FindFileData;
    HANDLE hFind = FindFirstFile(wPath.c_str(), &FindFileData);
    if (hFind == INVALID_HANDLE_VALUE) 
    {
        return false;
    }
    do
    {
        // Add to the list if this is not a directory
        if ((FindFileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) == 0)
        {
            // Convert wchar to char
            std::basic_string<TCHAR> wfilename(FindFileData.cFileName);
            std::string filename;
            filename.assign(wfilename.begin(), wfilename.end());
            files.push_back(filename);
        }
    } while (FindNextFile(hFind, &FindFileData) != 0);

    FindClose(hFind);
    return true;
#else
    std::string path(FileSystem::getResourcePath());
    if (dirPath && strlen(dirPath) > 0)
    {
        path.append(dirPath);
    }
    path.append("/.");
    bool result = false;

    struct dirent* dp;
    DIR* dir = opendir(path.c_str());
    if (dir != NULL)
    {
        while ((dp = readdir(dir)) != NULL)
        {
            std::string filepath(path);
            filepath.append("/");
            filepath.append(dp->d_name);

            struct stat buf;
            if (!stat(filepath.c_str(), &buf))
            {
                // Add to the list if this is not a directory
                if (!S_ISDIR(buf.st_mode))
                {
                    files.push_back(dp->d_name);
                }
            }
        }
        closedir(dir);
        result = true;
    }

    return result;
#endif
}

bool FileSystem::fileExists(const char* filePath)
{
    GP_ASSERT(filePath);

#ifdef HSPDISH
    {
        return (dpm_exist((char *)filePath)>=0);
    }
#else
    std::string fullPath;

    getFullPath(filePath, fullPath);

    gp_stat_struct s;
    return stat(fullPath.c_str(), &s) == 0;
#endif

}

Stream* FileSystem::open(const char* path, size_t streamMode)
{
    char modeStr[] = "rb";
    if ((streamMode & WRITE) != 0)
        modeStr[0] = 'w';

    std::string fullPath;
    getFullPath(path, fullPath);
    FileStream* stream = FileStream::create(fullPath.c_str(), modeStr);
    return stream;
}

char* FileSystem::readAll(const char* filePath, int* fileSize)
{
    GP_ASSERT(filePath);

#ifdef HSPDISH
	{
		size_t size = (size_t)dpm_exist((char *)filePath);
		if (size < 0) {
			GP_ERROR("Failed to load file: %s", filePath);
			return NULL;
		}
		char* buffer = new char[size + 1];
		dpm_read((char *)filePath, buffer, size, 0);
		// Force the character buffer to be NULL-terminated.
		buffer[size] = '\0';
		if (fileSize)
		{
			*fileSize = (int)size;
		}
		return buffer;
	}
#else
	// Open file for reading.
    std::unique_ptr<Stream> stream(open(filePath));
    if (stream.get() == NULL)
    {
        GP_ERROR("Failed to load file: %s", filePath);
        return NULL;
    }
    size_t size = stream->length();

    // Read entire file contents.
    char* buffer = new char[size + 1];
    size_t read = stream->read(buffer, 1, size);
    if (read != size)
    {
        GP_ERROR("Failed to read complete contents of file '%s' (amount read vs. file size: %u < %u).", filePath, read, size);
        SAFE_DELETE_ARRAY(buffer);
        return NULL;
    }

    // Force the character buffer to be NULL-terminated.
    buffer[size] = '\0';

    if (fileSize)
    {
        *fileSize = (int)size; 
    }
    return buffer;
#endif
}

bool FileSystem::isAbsolutePath(const char* filePath)
{
    if (filePath == 0 || filePath[0] == '\0')
        return false;
#ifdef WIN32
    if (filePath[1] != '\0')
    {
        char first = filePath[0];
        return (filePath[1] == ':' && ((first >= 'a' && first <= 'z') || (first >= 'A' && first <= 'Z')));
    }
    return false;
#else
    return filePath[0] == '/';
#endif
}

void FileSystem::setAssetPath(const char* path)
{
    __assetPath = path;
}

const char* FileSystem::getAssetPath()
{
    return __assetPath.c_str();
}


std::string FileSystem::getDirectoryName(const char* path)
{
    if (path == NULL || strlen(path) == 0)
    {
        return "";
    }
#ifdef WIN32
    char drive[_MAX_DRIVE];
    char dir[_MAX_DIR];
    _splitpath(path, drive, dir, NULL, NULL);
    std::string dirname;
    size_t driveLength = strlen(drive);
    if (driveLength > 0)
    {
        dirname.reserve(driveLength + strlen(dir));
        dirname.append(drive);
        dirname.append(dir);
    }
    else
    {
        dirname.assign(dir);
    }
    std::replace(dirname.begin(), dirname.end(), '\\', '/');
    return dirname;
#else
    // dirname() modifies the input string so create a temp string
    std::string dirname;
    char* tempPath = new char[strlen(path) + 1];
    strcpy(tempPath, path);
    char* dir = ::dirname(tempPath);
    if (dir && strlen(dir) > 0)
    {
        dirname.assign(dir);
        // dirname() strips off the trailing '/' so add it back to be consistent with Windows
        dirname.append("/");
    }
    SAFE_DELETE_ARRAY(tempPath);
    return dirname;
#endif
}

std::string FileSystem::getExtension(const char* path)
{
    const char* str = strrchr(path, '.');
    if (str == NULL)
        return "";

    std::string ext;
    size_t len = strlen(str);
    for (size_t i = 0; i < len; ++i)
        ext += std::toupper(str[i]);

    return ext;
}

//////////////////

FileStream::FileStream(DpmFile* file)
    : _file(file), _canRead(false), _canWrite(false)
{
    
}

FileStream::~FileStream()
{
    if (_file)
    {
        close();
    }
}

FileStream* FileStream::create(const char* filePath, const char* mode)
{
    DpmFile* file;
#ifdef HSPDISH
    file = (DpmFile*)dpm_stream((char *)filePath);
    if (file)
    {
        FileStream* stream = new FileStream(file);
        const char* s = mode;
        while (s != NULL && *s != '\0')
        {
            if (*s == 'r')
                stream->_canRead = true;
            else if (*s == 'w')
                stream->_canWrite = true;
            ++s;
        }

        return stream;
    }
#endif
    return NULL;
}

bool FileStream::canRead()
{
    return _file && _canRead;
}

bool FileStream::canWrite()
{
    return _file && _canWrite;
}

bool FileStream::canSeek()
{
    return _file != NULL;
}

void FileStream::close()
{
#ifdef HSPDISH
    if (_file) {
        _file->close();
        delete _file;
    }
#endif
    _file = NULL;
}

size_t FileStream::read(void* ptr, size_t size, size_t count)
{
#ifdef HSPDISH
    if (_file) {
        return _file->read(ptr,size,count);
    }
#endif
#if 0
    if (!_file)
        return 0;
    return fread(ptr, size, count, _file);
#endif
    return 0;
}

char* FileStream::readLine(char* str, int num)
{
#ifdef HSPDISH
    if (_file) {
        return _file->readLine(str,num);
    }
#endif
#if 0
    if (!_file)
        return 0;
    return fgets(str, num, _file);
#endif
    return 0;
}

size_t FileStream::write(const void* ptr, size_t size, size_t count)
{
#ifdef HSPDISH
    return 0;
#endif
#if 0
    if (!_file)
        return 0;
    return fwrite(ptr, size, count, _file);
#endif
}

bool FileStream::eof()
{
#ifdef HSPDISH
    if (_file) {
        return _file->eof();
    }
#endif
#if 0
    if (!_file || feof(_file))
        return true;
    return ((size_t)position()) >= length();
#endif
    return true;
}

size_t FileStream::length()
{
#ifdef HSPDISH
    if (_file) {
        return _file->length();
    }
#endif
#if 0
    size_t len = 0;
    if (canSeek())
    {
        long int pos = position();
        if (seek(0, SEEK_END))
        {
            len = position();
        }
        seek(pos, SEEK_SET);
    }
    return len;
#endif
    return -1;
}

long int FileStream::position()
{
#ifdef HSPDISH
    if (_file) {
        return _file->position();
    }
#endif
#if 0
    if (!_file)
        return -1;
    return ftell(_file);
#endif
    return -1;
}

bool FileStream::seek(long int offset, int origin)
{
#ifdef HSPDISH
    if (_file) {
        return _file->seek((int)offset,origin);
    }
#endif
#if 0
    if (!_file)
        return false;
    return fseek(_file, offset, origin) == 0;
#endif
    return false;
}

bool FileStream::rewind()
{
#ifdef HSPDISH
    if (_file) {
        return _file->rewind();
    }
#endif
#if 0
    if (canSeek())
    {
        ::rewind(_file);
        return true;
    }
#endif
    return false;
}

////////////////////////////////


}

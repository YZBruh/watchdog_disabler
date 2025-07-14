/*
   Copyright 2025 Yağız Zengin

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

	   http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#include <iostream>
#include <list>

#define LOG_TAG "disable_watchdog"
#include <android/log.h>
#include <android/log_macros.h>

bool suspendWatchdog(std::list<const char*> files)
{
	bool suspendOk = false;

	for (const auto& file : files) {
		int fd = open(file, O_WRONLY);
		if (fd == -1) {
			if (errno == ENOENT) {
				int last = errno;
				fd = open(file, O_WRONLY | O_CREAT, 644);
				if (fd == -1) {
					ALOGW("Cannot create %s: %s\n", file, strerror(errno));
					continue;
				}
			} else {
				ALOGW("Cannot open %s: %s\n", file, strerror(errno));
				continue;
			}
		}

		char ch = 'V';
		if (write(fd, &ch, 1) != 1) {
			ALOGW("Cannot write %s: %s\n", file, strerror(errno));
			close(fd);
			continue;
		}

		suspendOk = true;
		ALOGI("%s: successfully suspended.\n", file);
		close(fd);
	}

	return suspendOk;
}

int main(void)
{
	ALOGI("Service started.\n");

	while (1) {
		if (!suspendWatchdog({"/dev/watchdog1", "/dev/watchdog0", "/dev/watchdog"})) {
			ALOGE("watchdog suspend fail!\n");
			break;
		}
		sleep(8);
	}

	ALOGI("Service stopped!\n");
	return 1;
}

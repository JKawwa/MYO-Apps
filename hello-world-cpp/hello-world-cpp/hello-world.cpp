#include <iostream>
#include <myo.h>
#include <WinSock2.h>
#include <WS2tcpip.h>
#include <stdio.h>
#include <string.h>

#pragma comment(lib, "Ws2_32.lib")
#define DEFAULT_PORT "27015"
#define MAX_CLIENTS 10
#define DEFAULT_BUFLEN 512

void fistPoseDetected();
void inGestureDetected();
void outGestureDetected();
void pointPoseDetected();
void StartServer();
int AcceptClient();
int ProcessClient(SOCKET);
void sendCommand(char* cmd);

WSADATA wsaData;
SOCKET ListenSocket = INVALID_SOCKET;
SOCKET ClientSocket[MAX_CLIENTS];
int connectedDevices = 0;
int currentDevice = -1;
int targetDevice = 0;

void main() 
{
    
	for( int i = 0; i < MAX_CLIENTS; i++ )
	{
		ClientSocket[i] = INVALID_SOCKET;
	}

	StartServer();
	
	/*

    //Step 1: Create all the things
    myo::Hub hub;
    myo::SimpleDeviceListener deviceListener;

    //Step 2: Hook up the handlers for the events you care about
    deviceListener.onPoseStart().add([] (const myo::Pose& pose) {
        std::cout << "DETECTED" << std::endl;
		switch(pose.type())
		{
		case myo::PoseType::FIST:
			fistPoseDetected();
			break;

		case myo::PoseType::GUN:
			pointPoseDetected();
			break;

		case myo::PoseType::LEFT:
			inGestureDetected();
			break;

		case myo::PoseType::RIGHT:
			outGestureDetected();
			break;
		}
    });

	
	deviceListener.onMotion().add( [] (const myo::Motion& motion) {

	std::cout << static_cast<int32_t>(motion.poseType()) << std::endl;

	switch(motion.poseType())
	{
		case myo::PoseType::FIST:
			fistPoseDetected();
			break;

		case myo::PoseType::GUN:
			pointPoseDetected();
			break;

		case myo::PoseType::LEFT:
			inGestureDetected();
			break;

		case myo::PoseType::RIGHT:
			outGestureDetected();
			break;
	}

	//std::cout << motion.acceleration()

	});

    deviceListener.onPoseFinish().add([] (const myo::Pose& pose) {
        if (pose.type() == myo::PoseType::FIST) {
            std::cout << "UKEN" << std::endl;
        }
    });

    //Step 3: Add the listener to the default device
    hub.defaultDevice().addListener(deviceListener);

    std::cout << "Round 1: FIGHT!" << std::endl;
    std::cout << "Press enter to end";
    std::cin.ignore(); 

	*/

	//Main event loop
	while(true)
	{
		//Check if any new socket requests have arrived
		AcceptClient();

		for( int i = 0; i < connectedDevices; i++)
		{
			ProcessClient(ClientSocket[i]);
		}

		//Send any waiting commands


		if(connectedDevices == 1000)
		{
			std::cout << "Waiting for command" << std::endl;
			int input;
			std::cin >> input;

			if(input == 11)
			{
				std::cout << "Sending play command" << std::endl;
				sendCommand("play:songName.mp3@135");
			}
			if(input == 12)
			{
				std::cout << "Sending pause command" << std::endl;
				sendCommand("pause");
			}
			if(input == 13)
			{
				std::cout << "Sending next song command" << std::endl;
				sendCommand("next");
			}
			if(input == 14)
			{
				std::cout << "Sending prev song command" << std::endl;
				sendCommand("prev");
			}
			if(input == 15)
			{
				std::cout << "Sending info command" << std::endl;
				sendCommand("info");
			}
			if(input == 16)
			{
				std::cout << "Sending resume command" << std::endl;
				sendCommand("resume");
			}
			else
			{
				targetDevice = input;
				std::cout << "Target Device Set To " << targetDevice << std::endl;
				std::cout << "Current Device Set To " << currentDevice << std::endl;
			}
		}
	}
}

void pointPoseDetected()
{
	//Play media
	std::cout << "Point detected!" << std::endl;
}

void fistPoseDetected()
{
	//Stop media
	std::cout << "Fist detected!" << std::endl;
}

void inGestureDetected()
{
	//Previous song or rewind
	std::cout << "In-gesture detected!" << std::endl;
}

void outGestureDetected()
{
	//Next song or fast-forward
	std::cout << "Out-gesture detected!" << std::endl;
}

void StartServer()
{
	int iResult;
	// Initialize Winsock
	iResult = WSAStartup(MAKEWORD(2,2), &wsaData);
	if (iResult != 0) 
	{
		printf("WSAStartup failed: %d\n", iResult);
		abort();
	}

	std::cout << "Winsock initialized" << std::endl;

	struct addrinfo *result = NULL, *ptr = NULL, hints;

	ZeroMemory(&hints, sizeof (hints));
	hints.ai_family = AF_INET;
	hints.ai_socktype = SOCK_STREAM;
	hints.ai_protocol = IPPROTO_TCP;
	hints.ai_flags = AI_PASSIVE;

	// Resolve the local address and port to be used by the server
	iResult = getaddrinfo(NULL, DEFAULT_PORT, &hints, &result);
	if (iResult != 0) 
	{
		printf("getaddrinfo failed: %d\n", iResult);
		WSACleanup();
		abort();
	}

	std::cout << "getaddrinfo succeeded" << std::endl;
	printf("%s\n", result->ai_canonname);

	ListenSocket = socket(result->ai_family, result->ai_socktype, result->ai_protocol);

	if (ListenSocket == INVALID_SOCKET) 
	{
		printf("Error at socket(): %ld\n", WSAGetLastError());
		freeaddrinfo(result);
		WSACleanup();
		abort();
	}

	std::cout << "Socket created." << std::endl;\

	 // Setup the TCP listening socket
    iResult = bind( ListenSocket, result->ai_addr, (int)result->ai_addrlen);
    if (iResult == SOCKET_ERROR) 
	{
        printf("bind failed with error: %d\n", WSAGetLastError());
        freeaddrinfo(result);
        closesocket(ListenSocket);
        WSACleanup();
        abort();
    }

	std::cout << "Stuff I want " << result->ai_addr << std::endl;

	freeaddrinfo(result);

	std::cout << "Socket is bound." << std::endl;

	if ( listen( ListenSocket, SOMAXCONN ) == SOCKET_ERROR ) 
	{
		printf( "Listen failed with error: %ld\n", WSAGetLastError() );
		closesocket(ListenSocket);
		WSACleanup();
		abort();
	}

	std::cout << "Socket is listening..." << std::endl;

	u_long iMode=1;
	ioctlsocket(ListenSocket,FIONBIO,&iMode);
}

int AcceptClient()
{
	// Accept a client socket
	ClientSocket[connectedDevices] = accept(ListenSocket, NULL, NULL);
	if (ClientSocket[connectedDevices] == INVALID_SOCKET) 
	{
		//printf("accept failed: %d\n", WSAGetLastError());
		//closesocket(ListenSocket);
		//WSACleanup();
		return 1;
	}

	std::cout << "New device connected! Inserted in Slot " << connectedDevices << std::endl;
	connectedDevices++;
	currentDevice++;
	return 0;
}

int ProcessClient(SOCKET client)
{
	char recvbuf[DEFAULT_BUFLEN];
	int iResult, iSendResult;
	int recvbuflen = DEFAULT_BUFLEN;
	iResult = recv(client, recvbuf, recvbuflen, 0);
	
    if (iResult > 0)
	{
        printf("Bytes received: %d\n", iResult);

		char* recvStr = new char[iResult+1];
		strncpy(recvStr, recvbuf, iResult);
		recvStr[iResult] = '\0';
		printf("%s\n", recvbuf);
		//printf("%s\n", recvStr);

		if(strcmp(recvStr, "play") >= 0 && targetDevice != currentDevice)
		{
			//Song data received. Send pause command and switch to the active device
			sendCommand("pause");
			currentDevice = targetDevice;
			sendCommand(recvStr);
		}

		if(iResult == 3)
		{
			for(int i = 0; i < connectedDevices; i++)
			{
				if( client == ClientSocket[i] )
				{
					std::cout << "Active device asserted to be " << i << std::endl;
					currentDevice = i;
					break;
				}
			}
		}

		if(iResult == 4)
		{
			sendCommand("pause");
			std::cout << "pausing" << std::endl;
		}

		if(iResult == 5)
		{
			targetDevice = 0;
			std::cout << "target set to 0" << std::endl;
		}

		if(iResult == 6)
		{
			targetDevice = 1;
			std::cout << "target set to 1" << std::endl;
		}

		if(iResult == 7)
		{
			targetDevice = 2;
			std::cout << "target set to 2" << std::endl;
		}

		if(iResult == 8)
		{
			targetDevice = 3;
			std::cout << "target set to 3" << std::endl;
		}

		if(iResult == 9)
		{
			//Song data received. Send pause command and switch to the active device
			std::cout << "Swapping devices on GO command" << std::endl;
			sendCommand("pause");
			currentDevice = targetDevice;
			sendCommand("play:stuff.mp3:123");
		}

		if(iResult == 10)
		{
			currentDevice = targetDevice;
			std::cout << "current device set to " << targetDevice << std::endl;
		}

		if(iResult == 11)
		{
			sendCommand("info");
			std::cout << "sending command info to device " << currentDevice << std::endl;
		}
    }
	else if (iResult == 0)
	{
        //printf("Connection closing...\n");
		return -2;
	}
    else 
	{
        //printf("recv failed: %d\n", WSAGetLastError());
        //closesocket(client);
        //WSACleanup();
        return -1;
    }

}

void sendCommand(char* cmd)
{
	int iResult = 0;
	int iSendResult = send(ClientSocket[currentDevice], cmd, strlen(cmd), 0);

	if (iSendResult == SOCKET_ERROR) 
	{
        printf("send failed: %d\n", WSAGetLastError());
        return;
    }
}
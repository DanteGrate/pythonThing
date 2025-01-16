import pygame
import win32api
import win32con
import win32gui

import math
import random
import time
import keyboard

import ctypes

random.seed(time.time())

pygame.init()
ctypes.windll.user32.SetProcessDPIAware()
window_screen = pygame.display.set_mode((0, 0), pygame.NOFRAME)
# for borderless window use pygame.Noframe
# size of the pygame window will be of width 700 and height 450
hwnd = pygame.display.get_wm_info()["window"]
# Getting information of the current active window
win32gui.SetWindowLong(hwnd, win32con.GWL_EXSTYLE, 
    win32gui.GetWindowLong(hwnd, win32con.GWL_EXSTYLE) | win32con.WS_EX_LAYERED | win32con.WS_EX_TOOLWINDOW)


win32gui.SetLayeredWindowAttributes(hwnd, win32api.RGB(255, 0, 255), 0, win32con.LWA_COLORKEY)
# This will set the opacity and transparency color key of a layered window

win32gui.SetWindowPos(hwnd, win32con.HWND_TOPMOST, 0, 0, 0, 0, 
                      win32con.SWP_NOMOVE | win32con.SWP_NOSIZE)


clock = pygame.time.Clock()

audio = {
    "explosion0" : pygame.mixer.Sound("audio/explosion0.wav"),
    "explosion1" : pygame.mixer.Sound("audio/explosion1.wav"),
    "explosion2" : pygame.mixer.Sound("audio/explosion2.wav"),
    "hit0" : pygame.mixer.Sound("audio/hit0.wav"),
    "hit1" : pygame.mixer.Sound("audio/hit1.wav"),
    "hit2" : pygame.mixer.Sound("audio/hit2.wav"),
    "hit3" : pygame.mixer.Sound("audio/hit3.wav"),
    "shoot0" : pygame.mixer.Sound("audio/shoot0.wav"),
    "shoot1" : pygame.mixer.Sound("audio/shoot1.wav"),
    "shoot2" : pygame.mixer.Sound("audio/shoot2.wav"),
    "shoot3" : pygame.mixer.Sound("audio/shoot3.wav"),
    "shoot4" : pygame.mixer.Sound("audio/shoot4.wav"),
}

for key, sound in audio.items():
    sound.set_volume(0.1)

def playSound(sound):
    if sound == "exp":
        audio["explosion" + str(random.randint(0, 2))].play()
    elif sound == "hit":
        audio["hit" + str(random.randint(0, 3))].play()
    elif sound == "sho":
        audio["shoot" + str(random.randint(0, 4))].play()

font = pygame.font.Font("font/black.ttf", 64)

images = {
    "plane": {
        "base": pygame.image.load("image/plane/base.png"),
        "colour": pygame.image.load("image/plane/colour.png"),
        "shadow": pygame.image.load("image/plane/shadow.png").convert_alpha(),
        "prop0": pygame.image.load("image/plane/prop1.png"),
        "prop1": pygame.image.load("image/plane/prop2.png"),
        "prop2": pygame.image.load("image/plane/prop3.png"),
        "prop3": pygame.image.load("image/plane/prop4.png"),
    },
    "other": {
        "bullet": pygame.image.load("image/other/bullet.png"),
        "smoke": pygame.image.load("image/other/smoke.png"),
        "fire": pygame.image.load("image/other/fire.png"),
    }
}

teams = {
    "red": {
        "colour" : (255, 0, 0),
        "bColour" :(255, 255, 0),
        "spawnX" : window_screen.get_width() + 100,
        "spawnAngle" : 180,
        "score" : 0,
    },
    "blue": {
        "colour" : (0, 128, 255),
        "bColour" :(0, 255, 255),
        "spawnX" : - 100,
        "spawnAngle" : 0,
        "score" : 0,
    },
    "green": {
        "colour" : (128, 255, 128),
        "bColour" :(128, 255, 128),
        "spawnX" : window_screen.get_width()/2,
        "spawnAngle" : 90,
        "score" : 0,
    },
}

midX = window_screen.get_width()/2
midY = window_screen.get_height()/2



def tint_image(image, tint_color):
    tinted_image = image.copy()
    tinted_image.fill(tint_color, special_flags=pygame.BLEND_RGBA_MULT)
    return tinted_image

class Smoke:
    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.timer = 0

    def update(self, dt):
        self.timer = self.timer + dt


    def draw(self):
        window_screen.blit(images["other"]["smoke"], (self.x - 5, self.y + 5))

class Explosion:
    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.timer = 0.00000001

    def update(self, dt):
        self.timer = self.timer + dt
        dir = math.radians(random.randint(1, 360))
        smokeList.append(Smoke(self.x + math.cos(dir)*random.randint(1, math.ceil(50*self.timer)), self.y + math.sin(dir)*random.randint(1, math.ceil(50*self.timer))))


    def draw(self):
        for i in range(0, 5):
            dir = math.radians(random.randint(1, 360))
            window_screen.blit(images["other"]["fire"], (self.x + math.cos(dir)*40*self.timer, self.y + math.sin(dir)*40*self.timer))



class Bullet:
    def __init__(self, team, x, y, dir):
        self.x = x
        self.y = y
        self.angle = dir
        self.team = team
        self.timer = 0
        self.speed = 350
        playSound("sho")

    def update(self, dt):
        self.timer = self.timer + dt

        #have to convert angle to radians, drawing uses deg
        radians = math.radians(self.angle)

        self.x = self.x + math.cos(radians)*self.speed*dt
        self.y = self.y - math.sin(radians)*self.speed*dt

        #collisions LATERtm
        for plane in planeList:
            if plane.team != self.team:
                if math.sqrt((self.x - plane.x)*(self.x - plane.x) + (self.y - plane.y)*(self.y - plane.y)) < 25:
                    self.timer = 500 # kill next frame
                    plane.health = plane.health - 1
                    playSound("hit")
                    if plane.health == 0:
                        playSound("exp")
                        teams[self.team]["score"] += 1
                        planeList.append(Plane(plane.team))

                    smokeList.append(Smoke(self.x, self.y))

    def draw(self):
        rotated_base = pygame.transform.rotate(tint_image(images["other"]["bullet"], teams[self.team]["bColour"]), self.angle)
        rotated_rect = rotated_base.get_rect(center=(self.x, self.y))

        window_screen.blit(rotated_base, rotated_rect)


class Plane:
    def __init__(self, team):
        self.x = teams[team]["spawnX"] + random.randint(-30, 30)
        self.y = random.randint(0, midY*2)

        self.team = team
        self.speed = random.randint(100, 150)
        self.angle = teams[team]["spawnAngle"] + random.randint(-30, 30)
        self.timer = 0
        self.targetChangeTimer = 0
        self.target = None
        self.health = 5

        self.targeta = 0
        self.targetx = 0
        self.targety = 0
        self.targetSpeed = random.randint(75, 200)

        self.bulletCount = 6
        self.reloadTimer = random.randint(10, 300)/100
        self.shootCool = 0


    def rotate_towards(self, targetAngle, rotation_speed, dt):
        # Normalize angles to [0, 360)
        current_angle = self.angle % 360
        target_angle = targetAngle % 360

        # Calculate shortest angular difference
        diff = (target_angle - current_angle + 180) % 360 - 180

        # Cap the rotation speed
        max_rotation = rotation_speed * dt
        if abs(diff) > max_rotation:
            if diff > 0:
                diff = max_rotation 
            else: 
                diff = -max_rotation

        # Adjust the current angle
        self.angle += diff


    def update(self, dt):
        if self.health <= 0:
            self.health = self.health -1
            if self.health == - 1:
                smokeList.append(Explosion(self.x, self.y))
            return

        if self.health < 5:
            for i in range(1, 5-self.health):
                if random.randint(0,9) == 1:
                    smokeList.append(Smoke(self.x + random.randint(-10, 10), self.y + random.randint(-1, 10)))

        self.timer = self.timer + dt*10
        self.reloadTimer = self.reloadTimer - dt
        self.targetChangeTimer = self.targetChangeTimer - dt

        if self.targetChangeTimer <= 0:
            #pick a new target
            self.target = random.randint(0, len(planeList)-1)
            self.targetChangeTimer = random.randint(0, 50)/10 + 3
        else:
            #remove dead target
            if self.target:
                if len(planeList)-1 < self.target or planeList[self.target].health <= 0:
                    self.target = None
        
        if self.target:
            distToMid = math.sqrt((self.x - midX)**2 + (self.y - midY)**2)
            
            # Original target position
            tx = planeList[self.target].x
            ty = planeList[self.target].y

            # If beyond the boundary, blend between the target and the center
            if distToMid > 100:
                # Calculate the blending factor (0 near the center, 1 far away)
                blend = min((distToMid - 500) / 500, 1)  # Capped at 1

                # Blend target position towards the center
                tx = (1 - blend) * tx + blend * midX
                ty = (1 - blend) * ty + blend * midY

                self.targetx = tx
                self.targety = ty
            # Calculate the angle to the adjusted target
            targetAngle = math.atan2(self.y - ty, tx - self.x)
            self.targeta = targetAngle
            self.rotate_towards(math.degrees(targetAngle), 90, dt)

        if self.speed == self.targetSpeed and random.randint(0, 199) == 1:
            self.targetSpeed = random.randint(75, 200) 

        if self.speed < self.targetSpeed:
            self.speed = self.speed + dt*10
            if self.speed > self.targetSpeed:
                self.speed =self.targetSpeed
        elif self.speed > self.targetSpeed:
            self.sspeed =  self.speed - dt*10
            if self.speed < self.targetSpeed:
                self.speed =self.targetSpeed


        #have to convert angle to radians, drawing uses deg
        radians = math.radians(self.angle)

        self.x = self.x + math.cos(radians)*self.speed*dt
        self.y = self.y - math.sin(radians)*self.speed*dt

        #shooting
        if self.reloadTimer < 0:
            #diff = (target_angle - current_angle + 180) % 360 - 180
            if self.target and planeList[self.target].team != self.team and abs(self.angle- math.degrees(self.targeta)+ 180)%360 - 180 < 45:
                
                distToMid = math.sqrt((self.x - midX)**2 + (self.y - midY)**2)
                
                # Original target position
                tx = planeList[self.target].x
                if self.bulletCount > 0:
                    self.shootCool = self.shootCool - dt
                    if self.shootCool < 0:
                        #shoot
                        self.shootCool = 0.2
                        
                        self.bulletCount -= 1

                        bulletList.append(Bullet(self.team, self.x, self.y, self.angle))

                else:
                    self.reloadTimer = random.randint(1, 3)
                    self.bulletCount = 10
        else:
            pass



    def drawShadow(self):
        rotated_shadow = pygame.transform.rotate(images["plane"]["shadow"], self.angle).convert_alpha()
        rotated_rect = rotated_shadow.get_rect(center=(self.x, self.y + self.y))
        
        window_screen.blit(images["plane"]["shadow"], rotated_rect)

        

    def draw(self):
        #radians = math.radians(self.angle)
        if self.health > 0:
            rotated_base = pygame.transform.rotate(tint_image(images["plane"]["base"], teams[self.team]["colour"]), self.angle)
            rotated_colour = pygame.transform.rotate(images["plane"]["colour"], self.angle)
            rotated_prop = pygame.transform.rotate(images["plane"]["prop" + str(math.floor(self.timer%4))], self.angle)
            rotated_rect = rotated_base.get_rect(center=(self.x, self.y))

            window_screen.blit(rotated_base, rotated_rect)
            window_screen.blit(rotated_colour, rotated_rect)
            window_screen.blit(rotated_prop, rotated_rect)

           # pygame.draw.line(window_screen, (255, 0, 0), (self.x, self.y), (self.targetx, self.targety))

           # pygame.draw.line(window_screen, (0, 0, 255), (self.x, self.y), (self.x + math.cos(self.targeta)*100, self.y - math.sin(self.targeta)*100))
        


            
        
planeList = []
for i in range(0, 5):
    planeList.append(Plane("red"))
    planeList.append(Plane("blue"))
    #planeList.append(Plane("green"))


bulletList = []
smokeList = []

# Main loop
running = True
while running:
    dt = clock.tick(60) / 1000
        # Accessing the event if any occurred
    for event in pygame.event.get():    
        # Checking if quit button is pressed or not
        if event.type == pygame.QUIT:   
            #  If quit then store true
            running = False            
        # Checking if the escape button is pressed or not
        if event.type == pygame.KEYDOWN:    
            pass

     # Transparent backgroundcl
    window_screen.fill((255,0,255))

    bulletList = [bullet for bullet in bulletList if bullet.timer <= 10]
    for bullet in bulletList:
        bullet.update(dt)
        bullet.draw()

    planeList = [plane for plane in planeList if plane.health >= -10]

    for plane in planeList:
        plane.update(dt)
        plane.draw()

    smokeList = [smoke for smoke in smokeList if smoke.timer <= .3]
    for smoke in smokeList:
        smoke.update(dt)
        smoke.draw()

    if keyboard.is_pressed('ctrl'):
        # draw the score
        scoreText = font.render( str(teams["blue"]["score"]) + " - " + str(teams["red"]["score"]), True, (1,1,1))

        pygame.draw.rect(window_screen, (128, 128, 128), (midX - scoreText.get_width()/2 - 25, midY - scoreText.get_height()/2, scoreText.get_width() + 50, scoreText.get_height()), border_radius=20)

        window_screen.blit(scoreText, (midX - scoreText.get_width()/2, midY - scoreText.get_height()/2))

    #  Checking for the update in the display
    pygame.display.update()


pygame.quit()

#!/usr/bin/env python3

import os
from PIL import Image, ImageDraw, ImageFont
import json

# Icon sizes required for iOS apps
ICON_SIZES = [
    20, 29, 40, 58, 60, 80, 87, 120, 152, 167, 180, 1024
]

def create_progress_icon(size):
    """Create a progress-themed icon with a circular progress indicator and checkmark"""
    
    # Create image with solid white background
    img = Image.new('RGB', (size, size), (255, 255, 255))
    draw = ImageDraw.Draw(img)
    
    # Colors - modern iOS style
    bg_color = (52, 152, 219)  # Modern blue
    progress_color = (46, 204, 113)  # Green for progress
    check_color = (255, 255, 255)  # White checkmark
    
    # Create rounded rectangle background
    margin = size * 0.1
    corner_radius = size * 0.22
    
    # Draw rounded rectangle background
    draw.rounded_rectangle(
        [margin, margin, size - margin, size - margin],
        radius=corner_radius,
        fill=bg_color
    )
    
    # Draw progress circle
    circle_margin = size * 0.25
    circle_size = size - (2 * circle_margin)
    
    # Background circle (lighter)
    draw.ellipse(
        [circle_margin, circle_margin, circle_margin + circle_size, circle_margin + circle_size],
        outline=(255, 255, 255),
        width=max(1, size // 40)
    )
    
    # Progress arc (75% complete)
    progress_width = max(2, size // 20)
    draw.arc(
        [circle_margin, circle_margin, circle_margin + circle_size, circle_margin + circle_size],
        start=-90,
        end=180,  # 75% of 360 degrees
        fill=progress_color,
        width=progress_width
    )
    
    # Draw checkmark in center
    check_size = size * 0.15
    center_x, center_y = size // 2, size // 2
    
    # Checkmark path
    check_points = [
        (center_x - check_size * 0.6, center_y),
        (center_x - check_size * 0.1, center_y + check_size * 0.5),
        (center_x + check_size * 0.6, center_y - check_size * 0.3)
    ]
    
    # Draw checkmark with thicker line
    check_width = max(2, size // 30)
    for i in range(len(check_points) - 1):
        draw.line([check_points[i], check_points[i + 1]], fill=check_color, width=check_width)
    
    return img

def main():
    # Create icons directory
    icons_dir = "/Users/rvd/Work/Progress/Progress/Assets.xcassets/AppIcon.appiconset"
    
    print("Generating app icons...")
    
    # Generate all required sizes
    for size in ICON_SIZES:
        icon = create_progress_icon(size)
        
        # Save as PNG
        filename = f"icon_{size}x{size}.png"
        filepath = os.path.join(icons_dir, filename)
        icon.save(filepath, "PNG")
        print(f"Generated {filename}")
    
    # Update Contents.json with proper icon references
    contents = {
        "images": [
            {
                "filename": "icon_1024x1024.png",
                "idiom": "universal",
                "platform": "ios",
                "size": "1024x1024"
            },
            {
                "filename": "icon_20x20.png",
                "idiom": "iphone",
                "scale": "1x",
                "size": "20x20"
            },
            {
                "filename": "icon_40x40.png",
                "idiom": "iphone",
                "scale": "2x",
                "size": "20x20"
            },
            {
                "filename": "icon_60x60.png",
                "idiom": "iphone",
                "scale": "3x",
                "size": "20x20"
            },
            {
                "filename": "icon_29x29.png",
                "idiom": "iphone",
                "scale": "1x",
                "size": "29x29"
            },
            {
                "filename": "icon_58x58.png",
                "idiom": "iphone",
                "scale": "2x",
                "size": "29x29"
            },
            {
                "filename": "icon_87x87.png",
                "idiom": "iphone",
                "scale": "3x",
                "size": "29x29"
            },
            {
                "filename": "icon_40x40.png",
                "idiom": "iphone",
                "scale": "1x",
                "size": "40x40"
            },
            {
                "filename": "icon_80x80.png",
                "idiom": "iphone",
                "scale": "2x",
                "size": "40x40"
            },
            {
                "filename": "icon_120x120.png",
                "idiom": "iphone",
                "scale": "3x",
                "size": "40x40"
            },
            {
                "filename": "icon_120x120.png",
                "idiom": "iphone",
                "scale": "2x",
                "size": "60x60"
            },
            {
                "filename": "icon_180x180.png",
                "idiom": "iphone",
                "scale": "3x",
                "size": "60x60"
            },
            {
                "filename": "icon_20x20.png",
                "idiom": "ipad",
                "scale": "1x",
                "size": "20x20"
            },
            {
                "filename": "icon_40x40.png",
                "idiom": "ipad",
                "scale": "2x",
                "size": "20x20"
            },
            {
                "filename": "icon_29x29.png",
                "idiom": "ipad",
                "scale": "1x",
                "size": "29x29"
            },
            {
                "filename": "icon_58x58.png",
                "idiom": "ipad",
                "scale": "2x",
                "size": "29x29"
            },
            {
                "filename": "icon_40x40.png",
                "idiom": "ipad",
                "scale": "1x",
                "size": "40x40"
            },
            {
                "filename": "icon_80x80.png",
                "idiom": "ipad",
                "scale": "2x",
                "size": "40x40"
            },
            {
                "filename": "icon_152x152.png",
                "idiom": "ipad",
                "scale": "2x",
                "size": "76x76"
            },
            {
                "filename": "icon_167x167.png",
                "idiom": "ipad",
                "scale": "2x",
                "size": "83.5x83.5"
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    
    # Write updated Contents.json
    contents_path = os.path.join(icons_dir, "Contents.json")
    with open(contents_path, 'w') as f:
        json.dump(contents, f, indent=2)
    
    print("Updated Contents.json")
    print("App icons generated successfully!")

if __name__ == "__main__":
    main()
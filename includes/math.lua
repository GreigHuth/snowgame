--rounds x to nearest whole integer
function round(x)
    local y = x - flr(x)
    if y >= 0.5 then return ceil(x) 
    else  return flr(x)
    end
end

--finds the euclidean distance between two points
function e_dist(x, y, a, b)
    return sqrt((a-x)^2 + (b-y)^2)
end


--rotate pixel around given basis
function rotate_pixel(x, y, theta, basis_x, basis_y, b)

    if not b then b = false end
    if not basis_x then basis_x = 0 end
    if not basis_y then basis_y = 0 end

    x = x - basis_x --x translated
    y = y - basis_y

    local d = 360
    local a = 1
    local new_x = x*a*cos(theta/d) - y*a*sin(theta/d)
    local new_y = x*a*sin(theta/d) + y*a*cos(theta/d)

    --todo write special conditions for certain angles to fix how it looks?

    if b == false then
        return new_x +basis_x, new_y+basis_y
    else 
        return new_x, new_y
    end
end

--linear interpolation function
function lerp(p0, p1, ratio)
    return (1-ratio)*p0 + ratio*p1
end
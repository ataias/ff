using Transient
using NavierTypes
using Gadfly
@everywhere using Transient
@everywhere using NavierTypes
@everywhere using Gadfly

#N is a vector of all Ns that are going to be used!
# Run everything up to 1 or 2 times
function NavierStokesVaryingNTest(;Re=10, divFactor=1.25, t=1.0, N=[52])

  originalSTDOUT = STDOUT
  (outRead, outWrite) = redirect_stdout()

  date = Libc.strftime(time())
  println("$(date): NavierStokesVaryingNTest starting")
  println("\tRe=$(Re)")
  println("\tdivFactor=$(divFactor)")
  println("\tn=$(N)")

  # Forcing non-magnetic case
  c1 = 1
  Cpm = 0
  alpha = 1.0
  a, b = 0.1, 0.1 # precisa?
  # --------------------------

  # Frames per second
  fps = 50

  # In the unit tests, we are not saving the results
  save = false
  datafilename = "null"

  # Dictionary for which key is the mesh size n and its values are dictionaries
  # returne by transient()
  results = Dict{Int,Any}()

  #Simulações para casos não magnéticos

  @sync begin
    for n in N
      @async begin
        dt = getDt(maximum(N), Re, divFactor) # Use same dt for every case
        call = @spawn transient(n, dt, Re, t, Cpm, alpha, a, b, save, c1, fps, datafilename, should_print=false)
        results[n] = fetch(call)
      end
    end
  end

  # Need to know length of an array in results (depends on fps)
  points = length(results[N[1]][:t])
  midTPoint = round(Int, points/2)

  t = zeros(length(N))
  u = zeros(length(N))
  v = zeros(length(N))
  vortc = zeros(length(N))

  for i in range(1,length(N))
    k = N[i]
    # If you want to check whether the time point is actually the same,
    # uncomment the following two lines
    t[i] = results[k][:t][midTPoint]
    println("Time of N = " * string(N[i]) * " is " * string(t[i]))

    u[i] = results[k][:u][midTPoint]
    v[i] = results[k][:v][midTPoint]
    vortc[i] = results[k][:vortc][midTPoint]
  end

  # Data for regression and plotting
  dx = [1/(i-2) for i in N]
  dx2 = [x*x for x in dx]
  dx3 = [x*x*x for x in dx]
  base_u = u[length(N)]
  du = [abs(x - base_u) for x in u]

  # Linear regression of type du = w1 + w2*dx + w3*dx^2
  # We want a and b to be basically 0, this is how we assess this unit test passed
  # How great an epsilon should we choose? I don't know.

  # Linear regression to obtain w
  H = [ones(length(dx)) dx dx2]
  y = du
  w = (H'*H)\H'*y

  println("dx = $(dx)")
  println("error = $(du)")

  println("Coefficients:")
  println("w[1] = $(w[1])")
  println("w[2] = $(w[2])")
  println("w[3] = $(w[3])")
  # println("w[4] = $(w[4])")
  e = x -> w[1] + x*w[2] + x*x*w[3]# erro
  RSS = sum(map(x -> x*x, y - map(e, dx)))
  println("RSS = $(RSS)")

  # Plotting
  dxmin = minimum(dx)
  dxmax = maximum(dx)
  dxInterval = linspace(dxmin, dxmax, 100)
  dx2Interval = map(x -> x*x, dxInterval)
  value = map(e, dxInterval) # 100 pontos
  test_plot = plot(layer(x=dx2, y=du, Geom.point), layer(x=dx2Interval, y=value, Geom.line), Guide.XLabel("dx2"), Guide.YLabel("Error"), Guide.Title("Evolution of error: Re=" * string(Re) * ", divFactor=" * string(divFactor)))

  # Creating pdf
  nRe = round(Int, Re)
  ndF = round(Int, divFactor*100)
  pdfname = "NavierStokesVaryingNTest_Re$(nRe)_divFactor$(ndF).pdf"
  pngname = "NavierStokesVaryingNTest_Re$(nRe)_divFactor$(ndF).png"
  draw(PDF(pdfname, 8inch, 6inch), test_plot)
  draw(PNG(pngname, 8inch, 6inch), test_plot)

  # Show that plotting finished
  println("Finished plotting for test No Magnetism with Re=$(round(Int, Re)) and divFactor=$(divFactor))")
  println()

  close(outWrite)
  data = utf8(readavailable(outRead))
  close(outRead)
  redirect_stdout(originalSTDOUT)

  # command = `curl -s --user "api:$(mailgun[:API_KEY])" $(mailgun[:DOMAIN_NAME]) \
  #     -F from=$(mailgun[:from]) \
  #     -F to=$(mailgun[:to]) \
  #     -F subject="Simulation NavierStokesVaryingNTest of $(date)"  \
  #     -F text="Follows information about the test simulation that started at $(date)\n $(data)" \
  #     -F attachment=@$(abspath(pdfname)) \
  #     -F attachment=@$(abspath(pngname))`
  #
  #   try run(command) catch; end # for some reason, julia things an error happened
    println(data) # print data to screen, can be redirected using nohup
end

function NavierStokesVaryingDtTest(;Re=10, divFactor=[1.25,1.5,2.5], t=1.0, N=52)

  originalSTDOUT = STDOUT
  (outRead, outWrite) = redirect_stdout()

  date = Libc.strftime(time())
  println("$(date): NavierStokesVaryingDtTest starting")
  println("\tRe=$(Re)")
  println("\tdivFactor=$(divFactor)")
  println("\tn=$(N)")

  # Forcing non-magnetic case
  c1 = 1
  Cpm = 0
  alpha = 1.0
  a, b = 0.1, 0.1 # precisa?
  # --------------------------

  # Frames per second
  fps = 50

  # In the unit tests, we are not saving the results
  save = false
  datafilename = "null"

  # Dictionary for which key is the mesh size n and its values are dictionaries
  # returne by transient()
  results = Dict{Int,Any}()

  #Simulações para casos não magnéticos

  DT = [getDt(N, Re, dF) for dF in divFactor]

  i = 1
  @sync begin
    for dt in DT
      @async begin
        call = @spawn transient(N, dt, Re, t, Cpm, alpha, a, b, save, c1, fps, datafilename, should_print=false)
        results[i] = fetch(call)
      end
      i = i + 1
    end
  end

  # Need to know length of an array in results (depends on fps)
  points = length(results[1][:t])
  midTPoint = round(Int, points/2)

  t = zeros(length(divFactor))
  u = zeros(length(divFactor))
  v = zeros(length(divFactor))
  vortc = zeros(length(divFactor))

  for i in range(1,length(divFactor))
    # If you want to check whether the time point is actually the same,
    # uncomment the following two lines
    t[i] = results[i][:t][midTPoint]
    println("Time of dt = " * string(DT[i]) * " is " * string(t[i]))
    u[i] = results[i][:u][midTPoint]
    v[i] = results[i][:v][midTPoint]
    vortc[i] = results[i][:vortc][midTPoint]
  end

  dt = DT
  base_u = u[length(divFactor)]
  du = [abs(x) for x in u]

  # Linear regression of type du = w1 + w2*dx + w3*dx^2
  # We want a and b to be basically 0, this is how we assess this unit test passed
  # How great an epsilon should we choose? I don't know.

  # Linear regression to obtain w
  # H = [ones(length(dt)) dt map(x -> x*x, dt) map(x -> x*x*x, dt)]
  H = [ones(length(dt)) dt]
  y = du
  w = (H'*H)\H'*y

  println("dt = $(dt)")
  println("u = $(du)")

  println("Coefficients:")
  println("w[1] = $(w[1])")
  println("w[2] = $(w[2])")
  # println("w[3] = $(w[3])")
  # println("w[4] = $(w[4])")
  # e = x -> w[1] + x*w[2] + x*x*w[3] + x*x*x*w[4] # erro
  e = x -> w[1] + x*w[2] # erro
  RSS = sum(map(x -> x*x, y - map(e, dt)))
  println("RSS = $(RSS)")

  dtmin = minimum(dt)
  dtmax = maximum(dt)
  test_plot = plot(layer(x=dt, y=du, Geom.point), layer(e, dtmin, dtmax, Geom.line), Guide.XLabel("dt"), Guide.YLabel("Error"), Guide.Title("Evolution of error: Re=$(Re), n=$(N)"))
  nRe = round(Int, Re)
  pdfname = "NavierStokesVaryingDtTest_Re$(Re)_N$(N).pdf"
  pngname = "NavierStokesVaryingDtTest_Re$(Re)_N$(N).png"
  draw(PDF(pdfname, 8inch, 6inch), test_plot)
  # draw(PNG(pngname, 8inch, 6inch), test_plot)
  println("Finished plotting for test No Magnetism with Re=$(round(Int, Re)) and divFactor=$(divFactor)), dt varying, n fixed in $(N)")


  close(outWrite)
  data = utf8(readavailable(outRead))
  close(outRead)
  redirect_stdout(originalSTDOUT)
  println(data) # print data to screen, can be redirected using nohup

  #  command = `curl -s --user "api:$(mailgun[:API_KEY])" $(mailgun[:DOMAIN_NAME]) \
  #      -F from=$(mailgun[:from]) \
  #      -F to=$(mailgun[:to]) \
  #      -F subject="Simulation NavierStokesVaryingDtTest of $(date)"  \
  #      -F text="Follows information about the test simulation that started at $(date)\n $(data)" \
  #      -F attachment=@$(abspath(pdfname)) \
  #      -F attachment=@$(abspath(pngname))`
   #
  #   try run(command) catch; end # for some reason, julia thinks an error happened

end

function main()
  # @time NavierStokesVaryingNTest(Re=10.0, divFactor=2.5, t=1.0, N=2 + [100, 120, 140, 160])
  @time NavierStokesVaryingDtTest(Re=10, divFactor=[100.0, 200.0, 300.0, 400.0, 500.0, 600.0], t=1.0, N=52)
end

main()
